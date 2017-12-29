module Main exposing (..)

import HttpRequest
import Http
import Model exposing (Msg, Model, Project)
import Dict exposing (Dict)
import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)
import Markdown


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model [] Dict.empty
    , HttpRequest.getProjects
    )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Model.LoadingProjects (Ok projects) ->
            ( { model | projects = projects }, HttpRequest.getProjectDescriptions projects )

        Model.LoadingProjects (Err err) ->
            ( model, Cmd.none )

        Model.LoadingDescriptions (Ok projectDescriptions) ->
            let
                descriptions =
                    projectDescriptions
                        |> List.map (Markdown.toHtml [])
                        |> List.map2
                            (,)
                            (List.map .id model.projects)
                        |> Dict.fromList
                        |> Debug.log "Dictionary"
            in
                ( { model | projectDescriptions = descriptions }, Cmd.none )

        Model.LoadingDescriptions (Err err) ->
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



-- View


projectToDiv : Project -> Html msg
projectToDiv project =
    div [] [ text project.name ]


view : Model -> Html Msg
view model =
    div []
        (List.concat
            [ [ h1 [] [ text "Portfolio" ] ]
            , (List.map
                projectToDiv
                model.projects
              )
            , [ Maybe.withDefault
                    (text "Could not find description ang")
                    (Dict.get "ang" model.projectDescriptions)
              ]
            ]
        )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
