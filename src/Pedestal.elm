module Pedestal exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (href, src)
import Html.Events exposing (onClick)
import Bootstrap.Card as Card


-- Model


type alias Project =
    { id : String
    , name : String
    , date : String
    , link : String
    , description : String
    }


type alias Model =
    { project : Project
    }



-- Update


type Msg
    = Clicked Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Clicked pedestal ->
            let
                irr =
                    (Debug.log
                        "Pedestal clicked"
                        pedestal
                    )
            in
                ( model, Cmd.none )



-- View


card : Model -> Card.Config msg
card model =
    Card.config [ Card.attrs [] ]
        |> Card.imgTop [ src "http://via.placeholder.com/300" ] []
        |> Card.footer [] [ text model.project.date ]
        |> Card.block []
            [ Card.titleH4 [] [ text model.project.name ]
            , Card.text [] [ text model.project.description ]
            , (Card.link
                [ href ("#" ++ model.project.link) ]
                [ text "Project Link" ]
              )
            ]
