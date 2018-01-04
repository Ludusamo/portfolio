module Main exposing (..)

import HttpRequest
import Http
import Pedestal exposing (Project)
import Dict exposing (Dict)
import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)
import Markdown
import Task exposing (Task)
import Json.Decode as Decode
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Util.List as ListUtil
import Bootstrap.Card as Card
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Carousel as Carousel
import Bootstrap.Carousel.Slide as Slide


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model
        []
        []
        Pedestal.emptyProject
        Modal.hiddenState
        Carousel.initialState
        Dict.empty
    , getProjects
    )



-- Model


type alias Model =
    { projects : List Project
    , pedestals : List Pedestal.Model
    , selectedProject : Project
    , descriptionState : Modal.State
    , projectCarousel : Carousel.State
    , projectDescriptions : Dict String (Html Msg)
    }



-- Update


type Msg
    = LoadingProjects (Result Http.Error (List Project))
    | LoadingDescriptions (Result Http.Error (List String))
    | PedestalClick Pedestal.Model
    | ModalMsg Modal.State
    | CarouselMsg Carousel.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadingProjects (Ok projects) ->
            let
                pedestals =
                    projects
                        |> List.map (\project -> Pedestal.Model project)
            in
                ( { model
                    | pedestals = pedestals
                    , projects = projects
                  }
                , getProjectDescriptions projects
                )

        LoadingProjects (Err err) ->
            case err of
                Http.BadUrl errorMsg ->
                    Debug.log
                        errorMsg
                        ( model, Cmd.none )

                Http.Timeout ->
                    Debug.log
                        "Timeout"
                        ( model, Cmd.none )

                Http.NetworkError ->
                    Debug.log
                        "NetworkError"
                        ( model, Cmd.none )

                Http.BadStatus status ->
                    Debug.log
                        status.body
                        ( model, Cmd.none )

                Http.BadPayload status res ->
                    Debug.log
                        status
                        ( model, Cmd.none )

        LoadingDescriptions (Ok projectDescriptions) ->
            let
                descriptions =
                    projectDescriptions
                        |> List.map (Markdown.toHtml [])
                        |> List.map2
                            (,)
                            (List.map .id model.projects)
                        |> Dict.fromList
            in
                ( { model | projectDescriptions = descriptions }, Cmd.none )

        LoadingDescriptions (Err err) ->
            case err of
                Http.BadUrl errorMsg ->
                    Debug.log
                        errorMsg
                        ( model, Cmd.none )

                Http.Timeout ->
                    Debug.log
                        "Timeout"
                        ( model, Cmd.none )

                Http.NetworkError ->
                    Debug.log
                        "NetworkError"
                        ( model, Cmd.none )

                Http.BadStatus status ->
                    Debug.log
                        status.body
                        ( model, Cmd.none )

                Http.BadPayload status res ->
                    Debug.log
                        status
                        ( model, Cmd.none )

        PedestalClick pedestal ->
            { model
                | selectedProject = pedestal.project
                , projectCarousel = Carousel.initialState
            }
                |> update (ModalMsg Modal.visibleState)

        ModalMsg state ->
            ( { model | descriptionState = state }, Cmd.none )

        CarouselMsg subMsg ->
            ( { model
                | projectCarousel =
                    Carousel.update subMsg model.projectCarousel
              }
            , Cmd.none
            )



-- View


projectToDiv : Project -> Html msg
projectToDiv project =
    div [] [ text project.name ]


view : Model -> Html Msg
view model =
    Grid.container []
        ([ CDN.stylesheet
         , Grid.simpleRow
            [ Grid.col
                []
                [ h1 [] [ text "Portfolio" ] ]
            ]
         , descriptionModal model
         ]
            ++ (model.pedestals
                    |> ListUtil.group 3
                    |> List.map
                        (\group ->
                            (group
                                |> List.map
                                    (\pedestal ->
                                        (Pedestal.card
                                            (pedestalConfig pedestal)
                                            pedestal
                                        )
                                    )
                            )
                        )
                    |> List.map Card.deck
                    |> List.map
                        (\deck ->
                            Grid.simpleRow
                                [ Grid.col
                                    [ Col.attrs [], Col.xs12 ]
                                    [ deck ]
                                ]
                        )
               )
        )


descriptionModal : Model -> Html Msg
descriptionModal model =
    Modal.config ModalMsg
        |> Modal.large
        |> Modal.h5 [] [ text model.selectedProject.name ]
        |> Modal.body []
            [ projectCarousel model
            , let
                description =
                    Maybe.withDefault
                        (div [] [])
                        (Dict.get
                            model.selectedProject.id
                            model.projectDescriptions
                        )
              in
                description
            ]
        |> Modal.view model.descriptionState


projectCarousel : Model -> Html Msg
projectCarousel model =
    Carousel.config CarouselMsg []
        |> Carousel.withIndicators
        |> Carousel.slides
            (List.map
                (\imgLink -> Slide.config [] (Slide.image [] imgLink))
                model.selectedProject.carousel
            )
        |> Carousel.view model.projectCarousel


pedestalConfig : Pedestal.Model -> Card.Config Msg
pedestalConfig pedestal =
    Card.config [ Card.attrs [ onClick (PedestalClick pedestal) ] ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Carousel.subscriptions model.projectCarousel CarouselMsg



-- Http


getProjects : Cmd Msg
getProjects =
    Http.send LoadingProjects HttpRequest.getProjectConfig


getProjectDescriptions : List Project -> Cmd Msg
getProjectDescriptions projects =
    projects
        |> List.map HttpRequest.getProjectDescription
        |> Task.sequence
        |> Task.attempt LoadingDescriptions
