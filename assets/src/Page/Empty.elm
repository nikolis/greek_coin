module Page.Empty exposing (view)

import Html exposing (Html)


view : { title : String, content : Html msg }
view =
    { title = ""
    , content = Html.text ""
    }
