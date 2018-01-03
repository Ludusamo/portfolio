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
    , thumbnail : String
    , description : String
    }


emptyProject =
    Project "" "" "" "" "" ""


type alias Model =
    { project : Project
    }



-- View


card : Card.Config msg -> Model -> Card.Config msg
card config model =
    config
        |> Card.imgTop [ src model.project.thumbnail ] []
        |> Card.footer [] [ text model.project.date ]
        |> Card.block []
            [ Card.titleH4 [] [ text model.project.name ]
            , Card.text [] [ text model.project.description ]
            ]
