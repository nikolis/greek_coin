module Page.Home.Naview exposing (naview)


import Html exposing (Html,  button, div, fieldset, h1, input, li, text, textarea, ul, br,p, label, span, th, tr, thead, td, table, tbody, img, small, h5, a, nav)
import Html.Attributes exposing (attribute, class, placeholder, type_, value, id, style, size, src, name, autocomplete, scope, alt, classList)
import Html.Events exposing (onInput, onSubmit, onClick)
import Route exposing (Route)
import Page exposing (Page(..))
import Asset
import Svg exposing (path, g , rect, polygon, svg)
import Svg.Attributes exposing (d, height, width, x, y ,dx ,dy, points, viewBox, version)
import Session exposing (Session)
import Api exposing (Cred(..))

getClass : Int -> String
getClass tn = 
    case tn of 
        1 -> "nav_fix" 
        2 -> "nav_fix_other"
        _ -> "nav_fix_other"

naview : Session -> Int -> Html msg
naview session navT=
    case Session.cred session of
      Just (Cred val header) ->
          let
              _ = Debug.log "header" header
          in
          case String.isEmpty header of
              False ->
                  div[][]
              True ->
                 navViewContent navT
      Nothing ->
          navViewContent navT


navViewContent : Int -> Html msg
navViewContent navT =
        nav [id "menu-area",class ("navbar navbar-expand-lg navbar-light "++ (getClass navT)), style "margin-right" "8%", style "margin-left" "9%", style "width" "90%", style "vertical-align" "middle",style "margin-bottom" "25px"]
            [
            a [ class "navbar-brand logo", Route.href Route.Home ]
              [ {--img[Asset.src Asset.logoSvgHor, style "width" "85%"][]--}
                svgLogo
              ]
           ,  button [class "navbar-toggler", type_ "button", attribute "data-toggle" "collapse", attribute "data-target" "#navbarSupportedContent", attribute "aria-controls" "navbarSupportedContent", attribute "aria-expanded" "false", attribute "aria-label" "Toggle navigation", style "opacity" "1"]
              [ span [class "navbar-toggler-icon", style "color" "black"][]
              ] 
            , div [ class "collapse navbar-collapse ", id "navbarSupportedContent" ]
                  [  ul [ class "nav navbar-nav ml-auto pull-xs-right" ,style "display" "tab", style "border-spacing" "25px"]
                    [
                      li[class "nav-item"]
                      [
                        a [class "nav nav-outline-button",style "border" "0.2rem solid transparent",  style "font-weight" "bold", style "padding" "5px 10px", Route.href Route.Company][span[ style "letter-spacing" "1px"][text"COMPANY"]]
                      ]

                    , li[class "nav-item"]
                      [
                        a [class "nav nav-outline-button",style "border" "0.2rem solid transparent",  style "font-weight" "bold", style "padding" "5px 10px", Route.href Route.Prices][span[ style "letter-spacing" "0.5px"][span[style "letter-spacing" "1px"][text"PRICES"]]]
                      ]

                    , li[class "nav-item"]
                      [
                        a [class "nav nav-outline-button",style "border" "0.2rem solid transparent",   style "font-weight" "bold", style "padding" "5px 10px", Route.href Route.Faq][span[style "letter-spacing" "0.5px"][span[style "letter-spacing" "1px"][text"FAQ"]]]
                      ]

                    , li[class "nav-item"]
                      [
                        a [class "nav nav-outline-button",style "border" "0.2rem solid transparent", style "font-weight" "bold", style "padding" "5px 10px", Route.href Route.Contact][span[ style "letter-spacing" "0.5px"][span[style "letter-spacing" "1px"][text"CONTACT US"]]]
                      ]

                    , li [class "nav-item", style "max-width" "160px", style "margin-bottom" "10px"]
                      [
                        a [class "nav-outline-button nav", Route.href (Route.Login )][ span[style "letter-spacing" "0.5px", style "font-size" "1.25rem"][span[style "letter-spacing" "1px"][text "SIGN IN"]]]
                      ]
                    , li [class "nav-item", style "max-width" "160px"]
                      [
                          a[class "nav-button nav my-2 my-sm-0", Route.href (Route.Register)] [ span[style "text-shadow" "1px 0 rgba(0,99,166,1)", style "letter-spacing" "0.5px", style "font-size" "1.25rem"][span[style "letter-spacing" "1px", style "color" "rgba(0,99,166,1)"][text "SIGN UP"]]]
                      ]

                    ]
                  ]
            ]



svgLogo : Html msg
svgLogo = 
    svg [ version "1.1", id "Layer_1", x "0px", y "0px", viewBox "0 0 380 120", Svg.Attributes.style "enable-background:new 0 0 390 113;" ] [ g [] [ g [] [ Svg.path [ Svg.Attributes.class "st0", d "M81.9,40.1c4.9-7.2,3.1-17-4.1-21.9c-2.2-1.5-4.8-2.5-7.5-2.7l8.4-5.7l-2-2.9L55.1,21.4L33.5,6.9l-1.9,2.9 l8.4,5.7c-8.7,0.8-15.1,8.4-14.3,17.1c0.2,2.7,1.2,5.3,2.7,7.5c-15.3,14.8-15.7,39.2-0.9,54.5s39.2,15.7,54.5,0.9 S97.7,56.3,82.9,41C82.6,40.7,82.3,40.4,81.9,40.1L81.9,40.1z M80.6,31.2c0,2.2-0.6,4.3-1.8,6.2C78.4,38,78,38.5,77.6,39 c-0.5,0.5-0.9,1-1.5,1.4C71.6,44,65.3,43.8,61,40l-0.5-0.5c-0.6-0.6-1.2-1.3-1.6-2c-0.4-0.6-0.7-1.3-1-2s-0.5-1.4-0.6-2.2 c-0.1-0.7-0.2-1.3-0.2-2l0,0c0-0.7,0.1-1.3,0.2-1.9c1-6.4,7-10.8,13.4-9.8C76.5,20.5,80.7,25.5,80.6,31.2L80.6,31.2z M55.5,39.5 c1,1.5,2.2,2.9,3.6,4l-0.3,0.4l-1.1,1.9l-1.1,1.9l-1.5,2.6l-1.5-2.6l-1.1-1.9l-1-1.9l-0.2-0.4c1.4-1.1,2.6-2.5,3.5-4H55.5z M55.1,58.3l5.7-9.8c8.5,2.5,14.4,10.3,14.4,19.2l0,0c0,11.1-9,20.1-20.1,20.1s-20-9-20-20.1l0,0l0,0c0-8.9,5.9-16.7,14.4-19.3 L55.1,58.3z M41.4,19.5c5.7,0,10.6,4.2,11.6,9.8c0.1,0.6,0.2,1.3,0.2,1.9l0,0c0,0.7-0.1,1.4-0.2,2c-0.1,0.8-0.4,1.5-0.6,2.2 c-0.3,0.7-0.6,1.4-1,2c-0.5,0.7-1,1.4-1.6,2L49.1,40c-0.5,0.5-1,0.9-1.6,1.2c-0.6,0.4-1.2,0.7-1.8,0.9c-3.9,1.6-8.4,1-11.7-1.6 c-0.5-0.4-1-0.9-1.5-1.4c-0.4-0.5-0.8-1-1.2-1.6c-3.4-5.6-1.7-12.8,3.8-16.2C37,20.1,39.1,19.5,41.4,19.5L41.4,19.5z M55.1,102.3 c-19.1,0-34.5-15.5-34.5-34.6l0,0l0,0c0-9.3,3.7-18.2,10.4-24.7c2.9,2.5,6.5,3.9,10.4,3.9c0.5,0,1.1,0,1.6-0.1 c-7.4,4.3-12,12.3-12,20.9l0,0C31.3,81,42.4,91.5,55.7,91.2c12.8-0.3,23.1-10.7,23.5-23.5l0,0c0-8.6-4.6-16.5-12.1-20.8 c0.6,0.1,1.1,0.1,1.7,0.1c3.8,0,7.5-1.4,10.4-3.9c6.6,6.5,10.4,15.3,10.4,24.6l0,0C89.6,86.8,74.2,102.2,55.1,102.3L55.1,102.3z" ] [], Svg.path [ Svg.Attributes.class "st0", d "M38.4,35.3c0.8,0.6,1.7,0.9,2.7,1h0.3c0.3,0,0.6,0,1-0.1c0.6-0.1,1.2-0.4,1.7-0.7c0.3-0.2,0.7-0.5,0.9-0.7 c0.7-0.7,1.1-1.5,1.3-2.5c0.1-0.4,0.1-0.7,0.1-1.1c0-0.3,0-0.7-0.1-1c-0.6-2.7-3.3-4.5-6-3.9c-2.3,0.5-4,2.5-4,4.9 C36.3,32.8,37.1,34.4,38.4,35.3z" ] [], Svg.path [ Svg.Attributes.class "st0", d "M55.1,63.2v-4c-5.1,0-9.5,3.6-10.6,8.5c-0.2,0.8-0.3,1.6-0.3,2.4c0,6,4.9,10.9,11,10.9 c4.4,0,8.3-2.6,10.1-6.7c0.6-1.4,0.9-2.8,0.9-4.3v-1.9h-11v4h6.6c0,0.2-0.2,0.5-0.3,0.7c-1.5,3.5-5.6,5.2-9.1,3.7 c-2.6-1.1-4.2-3.6-4.2-6.4c0-0.8,0.1-1.6,0.4-2.4C49.7,65,52.2,63.2,55.1,63.2z" ] [], Svg.path [ Svg.Attributes.class "st0", d "M63.9,30.2c-0.1,0.3-0.1,0.7-0.1,1c0,0.4,0,0.7,0.1,1.1c0.5,2,2,3.5,4,3.9c0.3,0.1,0.7,0.1,1,0.1h0.3 c1-0.1,1.9-0.4,2.7-1c1.3-1,2.1-2.5,2.1-4.1c0-2.8-2.3-5-5.2-5C66.4,26.3,64.4,27.9,63.9,30.2L63.9,30.2z" ] [] ], g [] [ Svg.path [ Svg.Attributes.class "st0", d "M308.6,39.9c-9.2,0-16.5,7.3-16.5,16.5c0,9.2,7.3,16.5,16.5,16.5s16.5-7.3,16.5-16.5l0,0 C325.2,47.4,317.8,39.9,308.6,39.9z M308.6,66.3c-5.5,0-9.9-4.4-9.9-9.9s4.4-9.9,9.9-9.9c5.5,0,9.9,4.4,9.9,9.9 C318.6,61.9,314.2,66.3,308.6,66.3L308.6,66.3z" ] [], Svg.path [ Svg.Attributes.class "st0", d "M273.6,63.6c-3.7-4-3.3-10.3,0.7-14c3.7-3.5,9.5-3.5,13.2,0l4.8-4.8c-6.4-6.4-17.1-6.4-23.5,0 c-6.4,6.4-6.4,17.1,0,23.5c6.4,6.4,16.9,6.4,23.5,0l-4.8-4.8C283.7,67.4,277.4,67.4,273.6,63.6L273.6,63.6z" ] [], Svg.path [ Svg.Attributes.class "st0", d "M176,51.1c0.2-2.9-1.1-5.7-3.5-7.5c-2.4-1.8-5.3-2.9-8.3-2.8h-12.9v31.8h7.2V46.3h4.4 c3.1-0.2,5.7,2.2,5.9,5.3c0,0.2,0,0.4,0,0.7c0,3.1-2.4,6.1-7.5,6.6v0.7l8.4,13h8.1L169.4,61C173.5,59,176,55.3,176,51.1z" ] [], polygon [ Svg.Attributes.class "st0", points "189.1,58.6 201.9,58.6 201.9,53.3 189.1,53.3 189.1,46.1 203.6,46.1 203.6,40.6 181.9,40.6 181.9,72.4 204.5,72.4 204.5,66.9 189.1,66.9 " ] [], polygon [ Svg.Attributes.class "st0", points "216.6,58.6 229.5,58.6 229.5,53.3 216.6,53.3 216.6,46.1 231,46.1 231,40.6 209.5,40.6 209.5,72.4 231.9,72.4 231.9,66.9 216.6,66.9 " ] [], polygon [ Svg.Attributes.class "st0", points "263.3,40.6 255.6,40.6 244,55.3 244,40.6 236.8,40.6 236.8,72.4 244,72.4 244,56.6 255.9,72.4 264.2,72.4 250.8,56.1 " ] [], rect [ x "330.1", y "40.8", Svg.Attributes.class "st0", width "7.2", height "31.8" ] [], Svg.path [ Svg.Attributes.class "st0", d "M365,40.8v17.8h-0.2c-2.2-2-5.5-5.1-9.9-9c-4.4-4-7.7-7-9.9-9.4h-1.1v32.3h7.2V54.2h0.2l19.8,18.9h0.9V40.8 L365,40.8L365,40.8z" ] [], Svg.path [ Svg.Attributes.class "st0", d "M121.9,56.6c0-5.3,4.2-9.5,9.4-9.9v-6.6c-9.2,0.2-16.3,7.9-16.2,17.1s7.9,16.3,17.1,16.2 c9-0.2,16.2-7.7,16.2-16.7v-3.3h-15.6v6.6h8.3l-0.4,0.7c-2.2,5-8.1,7.2-13,5C124.1,64.1,121.7,60.5,121.9,56.6L121.9,56.6z" ] [] ] ] ]


