module HttpRequest exposing (..)

import Http
import Model exposing (Model, Msg, Project)
import Task exposing (Task)
import Json.Decode as Decode


getProjects : Cmd Msg
getProjects =
    Http.send Model.LoadingProjects getProjectConfig


getProjectConfig : Http.Request (List Project)
getProjectConfig =
    Http.get "/res/projects.json" projectDataDecoder


getProjectDescriptions : List Project -> Cmd Msg
getProjectDescriptions projects =
    projects
        |> List.map getProjectDescription
        |> Task.sequence
        |> Task.attempt Model.LoadingDescriptions


getProjectDescription : Project -> Task Http.Error String
getProjectDescription project =
    let
        url =
            Debug.log "url" ("/res/descriptions/" ++ project.id ++ ".md")
    in
        Http.toTask (Http.getString url)


projectDataDecoder : Decode.Decoder (List Project)
projectDataDecoder =
    (Decode.list Model.projectDecoder)
