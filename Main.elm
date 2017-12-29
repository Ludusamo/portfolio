module Main exposing (..)

import Http
import Json.Decode exposing (..)
import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)
import Task exposing (Task)
import Markdown


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias Project =
    { id : String
    , name : String
    }


type alias Model =
    { projects : List Project
    , projectDescriptions : List (Html Msg)
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] []
    , getProjects
    )



-- Update


type Msg
    = LoadingProjects (Result Http.Error (List Project))
    | LoadingDescriptions (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadingProjects (Ok projects) ->
            ( { model | projects = projects }, getProjectDescriptions projects )

        LoadingProjects (Err err) ->
            ( model, Cmd.none )

        LoadingDescriptions (Ok projectDescriptions) ->
            let
                descriptions =
                    (Debug.log
                        "Received Descriptions"
                        (projectDescriptions
                            |> List.map parseMarkdownHtml
                            |> List.map (Markdown.toHtml [])
                        )
                    )
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
            , model.projectDescriptions
            ]
        )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Http


parseMarkdownHtml : String -> String
parseMarkdownHtml htmlString =
    htmlString
        |> String.split "<code>"
        |> List.drop 1
        |> List.head
        |> Maybe.withDefault ""
        |> String.split "</code>"
        |> List.take 1
        |> List.head
        |> Maybe.withDefault ""


getProjects : Cmd Msg
getProjects =
    Http.send LoadingProjects getProjectConfig


getProjectConfig : Http.Request (List Project)
getProjectConfig =
    Http.get "res/projects.json" projectDataDecoder


getProjectDescriptions : List Project -> Cmd Msg
getProjectDescriptions projects =
    projects
        |> List.map getProjectDescription
        |> Task.sequence
        |> Task.attempt LoadingDescriptions


getProjectDescription : Project -> Task Http.Error String
getProjectDescription project =
    let
        url =
            Debug.log "url" ("res/descriptions/" ++ project.id ++ ".md")
    in
        Http.toTask (Http.getString url)


projectDecoder : Decoder Project
projectDecoder =
    map2 Project
        (field "id" string)
        (field "name" string)


projectDataDecoder : Decoder (List Project)
projectDataDecoder =
    (list projectDecoder)
