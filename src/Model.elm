module Model exposing (..)

import Dict exposing (Dict)
import Html exposing (Html)
import Http
import Json.Decode as Decode


type alias Project =
    { id : String
    , name : String
    }


projectDecoder : Decode.Decoder Project
projectDecoder =
    Decode.map2 Project
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)


type Msg
    = LoadingProjects (Result Http.Error (List Project))
    | LoadingDescriptions (Result Http.Error (List String))


type alias Model =
    { projects : List Project
    , projectDescriptions : Dict String (Html Msg)
    }
