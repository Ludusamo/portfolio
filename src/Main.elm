module Main exposing (..)

import Http
import Json.Decode exposing (..)
import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias Project =
    { name : String
    }


type alias Model =
    { projects : List Project
    }


init : ( Model, Cmd Msg )
init =
    ( Model []
    , getProjectConfig
    )



-- Update


type Msg
    = LoadingProjects (Result Http.Error (List Project))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadingProjects (Ok projects) ->
            ( Model projects, Cmd.none )

        LoadingProjects (Err msg) ->
            ( Model [], Cmd.none )



-- View


projectToDiv : Project -> Html msg
projectToDiv project =
    div [] [ text project.name ]


view : Model -> Html Msg
view model =
    div []
        (List.append
            [ h1 [] [ text "Portfolio" ] ]
            (List.map
                projectToDiv
                model.projects
            )
        )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Http


getProjectConfig : Cmd Msg
getProjectConfig =
    Http.send LoadingProjects (Http.get "../res/projects.json" projectDataDecoder)


projectDecoder : Decoder Project
projectDecoder =
    map Project (field "name" string)


projectDataDecoder : Decoder (List Project)
projectDataDecoder =
    (list projectDecoder)
