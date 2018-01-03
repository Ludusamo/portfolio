module HttpRequest exposing (..)

import Http
import Pedestal exposing (Project)
import Json.Decode as Decode
import Task exposing (Task)


projectDataDecoder : Decode.Decoder (List Project)
projectDataDecoder =
    (Decode.list projectDecoder)


projectDecoder : Decode.Decoder Project
projectDecoder =
    Decode.map6 Project
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "date" Decode.string)
        (Decode.field "link" Decode.string)
        (Decode.field "thumbnail" Decode.string)
        (Decode.field "description" Decode.string)


getProjectConfig : Http.Request (List Project)
getProjectConfig =
    Http.get "/res/projects.json" projectDataDecoder


getProjectDescription : Project -> Task Http.Error String
getProjectDescription project =
    let
        url =
            "/res/descriptions/" ++ project.id ++ ".md"
    in
        Http.toTask (Http.getString url)
