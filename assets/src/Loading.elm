module Loading exposing (error, icon, slowThreshold, iconBig)

{-| A loading spinner icon.
-}

import Asset
import Html exposing (Attribute, Html)
import Html.Attributes exposing (alt, height, src, width, style)
import Process
import Task exposing (Task)


icon : Html msg
icon =
    Html.img
        [ Asset.src Asset.loading
        , width 64
        , height 64
        , alt "Loading..."
        ]
        []
iconBig : Html msg
iconBig =
    Html.img
        [ Asset.src Asset.loading
        , style "width" "15vw"
        , style "height" "15vh"
        , alt "Loading..."
        ]
        []



error : String -> Html msg
error str =
    Html.text ("Error loading " ++ str ++ ".")


slowThreshold : Task x ()
slowThreshold =
    Process.sleep 500
