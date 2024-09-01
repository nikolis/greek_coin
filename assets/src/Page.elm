module Page exposing (Page(..), view, viewErrors, viewModal)

import Api exposing (Cred)
import Avatar
import Browser exposing (Document)
import Html exposing (Html, a, button, div, footer, i, img, li, nav, p, span, text, ul, h5, br, h1, h2, input, iframe, node, strong)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Profile
import Route exposing (Route)
import Session exposing (Session)
import Username exposing (Username)
import Viewer exposing (Viewer)
import Api.Data exposing (Treasury)
import Api2.Data exposing (Withdraw)
import Asset
import Svg.SvgLogo exposing (svgLogo) 
import Svg exposing (path, g , rect, polygon, svg)
import Svg.Attributes exposing (d, height, width, x, y ,dx ,dy, points, viewBox, version)
import Page.Exchange.TransactionsView exposing (getUserAssets2, getUserAssets, dropDown)
import Page.Exchange.Transactions

svgEdit : Html msg
svgEdit =
  svg [ version "1.1", id "Layer_1", x "0px", y "0px", viewBox "0 0 330 330", Svg.Attributes.style "enable-background:new 0 0 330 330;" ] [ g [ id "XMLID_446_" ] [ Svg.path [ id "XMLID_447_", d "M115,125.5c34.601,0,62.751-28.149,62.751-62.75S149.601,0,115,0C80.399,0,52.25,28.149,52.25,62.75 S80.399,125.5,115,125.5z M115,30c18.059,0,32.751,14.691,32.751,32.75S133.059,95.5,115,95.5 c-18.059,0-32.751-14.691-32.751-32.75S96.941,30,115,30z" ] [], Svg.path [ id "XMLID_450_", d "M325.606,179.727l-45.333-45.333c-2.813-2.813-6.628-4.394-10.606-4.394 c-3.978,0-7.794,1.581-10.607,4.394l-58.854,58.854c-21.63-23.9-52.364-37.747-85.206-37.747c-63.411,0-115,51.589-115,115 c0,8.284,6.716,15,15,15h115V315c0,8.284,6.716,15,15,15h45.333c3.978,0,7.793-1.581,10.606-4.394L325.606,200.94 C331.464,195.082,331.464,185.585,325.606,179.727z M115,185.5c24.769,0,47.912,10.665,63.95,29.004L137.954,255.5H31.325 C38.431,215.761,73.249,185.5,115,185.5z M184.12,300H160v-24.12l49.227-49.228c0.09-0.087,0.178-0.176,0.265-0.265l60.174-60.174 l24.12,24.12L184.12,300z" ] [] ] ]

svgLogout : Html msg
svgLogout = 
    svg [ version "1.1", id "Capa_1", x "0px", y "0px", viewBox "0 0 490.3 490.3", Svg.Attributes.style "enable-background:new 0 0 490.3 490.3;" ] [ g [] [ Svg.path [ d "M318.5,315c-3.1-2.1-6.8-3.3-10.8-3.3c-2.6,0-5.2,0.5-7.5,1.5c-3.5,1.5-6.4,3.9-8.5,7c-2.1,3.1-3.3,6.8-3.3,10.8v37.3 c0,3.7-0.8,7.2-2.1,10.5c-2,4.8-5.5,9-9.8,11.9c-4.3,2.9-9.5,4.6-15.1,4.6H75.3c-3.7,0-7.2-0.8-10.5-2.1c-4.8-2-9-5.5-11.9-9.8 c-2.9-4.3-4.6-9.5-4.6-15.1V138c0-3.7,0.8-7.2,2.1-10.5c2-4.8,5.5-9,9.8-11.9c4.3-2.9,9.5-4.6,15.1-4.6h186.2 c3.7,0,7.2,0.8,10.5,2.1c4.8,2,9,5.5,11.9,9.8c2.9,4.3,4.6,9.5,4.6,15.1v37.3c0,2.6,0.5,5.2,1.5,7.5c1.5,3.5,3.9,6.4,7,8.5 c3.1,2.1,6.8,3.3,10.8,3.3c2.6,0,5.2-0.5,7.5-1.5c3.5-1.5,6.4-3.9,8.5-7c2.1-3.1,3.3-6.8,3.3-10.8V138c0-9-1.8-17.6-5.2-25.5 c-5-11.8-13.3-21.8-23.8-28.8c-10.4-7.1-23.1-11.2-36.6-11.2H75.3c-9,0-17.6,1.8-25.5,5.2C38,82.6,28,90.9,21,101.3 C13.9,111.8,9.7,124.4,9.7,138v230.3c0,9,1.8,17.6,5.2,25.5c5,11.8,13.3,21.8,23.7,28.8c10.4,7.1,23.1,11.2,36.6,11.2h186.2 c9,0,17.6-1.8,25.5-5.2c11.8-5,21.8-13.3,28.8-23.8c7.1-10.4,11.2-23.1,11.2-36.6V331c0-2.6-0.5-5.2-1.5-7.5 C324,320,321.5,317.1,318.5,315z" ] [], Svg.path [ d "M479.1,245.9c-0.9-2.3-2.4-4.5-4.2-6.4L397,161.6c-1.9-1.9-4-3.3-6.4-4.2c-2.3-0.9-4.8-1.4-7.2-1.4c-2.5,0-4.9,0.5-7.2,1.4 c-2.3,0.9-4.5,2.4-6.4,4.2c-1.9,1.9-3.3,4-4.2,6.4c-0.9,2.3-1.4,4.8-1.4,7.2c0,2.5,0.5,4.9,1.4,7.2c0.9,2.3,2.4,4.5,4.2,6.4l45,45 l-194.3,0c-2.6,0-5.2,0.5-7.5,1.5c-3.5,1.5-6.4,3.9-8.5,7c-2.1,3.1-3.3,6.8-3.3,10.8c0,2.6,0.5,5.2,1.5,7.5c1.5,3.5,3.9,6.4,7,8.5 c3.1,2.1,6.8,3.3,10.8,3.3h194.2l-45,45l0,0c-1.9,1.8-3.3,4-4.2,6.3c-1,2.3-1.4,4.8-1.4,7.3c0,2.5,0.5,4.9,1.4,7.3 c0.9,2.3,2.4,4.5,4.2,6.3l0,0c0,0,0,0,0,0c0,0,0,0,0,0l0,0c1.8,1.8,4,3.2,6.3,4.2c2.3,1,4.8,1.4,7.3,1.4c2.5,0,5-0.5,7.3-1.4 c2.3-0.9,4.5-2.4,6.4-4.2l77.9-77.9c1.9-1.9,3.3-4,4.2-6.4c0.9-2.3,1.4-4.8,1.4-7.2C480.6,250.7,480.1,248.2,479.1,245.9z" ] [] ] ]


type Page
    = Other
    | Home
    | Login
    | Register
    | Settings
    | Profile 
    | NewArticle
    | Prices
    | Transaction
    | Contact
    | About
    | Payments
    | Withdraw
    | Faq
    | Company
    | Verification
    | Cookies
    | FeeTable
    | Kyc
    | Privacy
    | Terms
    | Licenses

maskStyle : List (Html.Attribute msg)
maskStyle =
    [ style "background-color" "rgba(0,0,0,0.3)"
    , style "position" "fixed"
    , style "top" "0"
    , style "left" "0"
    , style "width" "100%"
    , style "height" "100%"
    , id "o kippppp"
    , style "z-index" "30"
    ]

modalStyle : List (Html.Attribute msg)
modalStyle =
    [ style "background-color" "rgba(255,255,255,1.0)"
    , style "position" "absolute"
    , style "top" "50%"
    , style "left" "50%"
    , style "height" "auto"
    , style "max-height" "80%"
    , style "width" "500px"
    , style "max-width" "95%"
    , style "padding" "10px"
    , style "border-radius" "15px"
    , style "box-shadow" "1px 1px 5px rgba(0,0,0,0.5)"
    , style "transform" "translate(-50%, -50%)"
    ]


view : Maybe Page.Exchange.Transactions.Model -> Maybe Viewer -> Maybe (List Treasury) -> Maybe (List Withdraw) -> Page -> { title : String, content : Html msg } -> Document msg
view  transactionsMaybe  maybeViewer treasury withdraws page { title, content } =
    { title = title ++ " - Greek Coin"
    , body = viewHeader transactionsMaybe page treasury withdraws maybeViewer :: div[][{--viewCookies--} content,(node "intl-date"[id "chatButton",style "position" "fixed" ,style "top" "0", style "right" "0", style "width" "200px", style "height" "200px", style "z-index" "1000"][text ""])] :: [ {--(viewFooter) --}]
    }

viewModal : Maybe Page.Exchange.Transactions.Model -> Maybe Viewer -> Maybe (List Treasury) -> Maybe (List Withdraw) -> Page -> { title : String, content : Html msg } -> Maybe (Html msg)   -> Document msg
viewModal  transactionMaybe  maybeViewer treasury withdraws page { title, content } modalContent  =
    { title = title ++ " - Greek Coin"
    , body = viewHeader transactionMaybe page treasury withdraws  maybeViewer ::
       (case modalContent of
          Just mContent ->
                div  maskStyle 
                [ div  modalStyle 
                  [  mContent]
                ]
          Nothing ->
             div[][] 
         )
       ::
        div[]
        [
         content
        , (node "intl-date"[id "chatButton"][])
        ]
       :: []
    }

viewHeader : Maybe Page.Exchange.Transactions.Model  -> Page -> Maybe (List Treasury) -> Maybe (List Withdraw) -> Maybe Viewer -> Html msg
viewHeader transM page treasury withdraws maybeViewer =
  case maybeViewer of 
      Nothing ->
          div[][]
      Just viewer ->
          let
             userName =  Username.toString (Viewer.username viewer)
          in
          case String.isEmpty userName of 
              True ->
                  div[][]
              False ->
                        nav [id "menu-area", class "navbar navbar-expand-lg navbar_light other ", style "padding-left" "9%", style "z-index" "10" ,style "background-color" "rgb(0, 99, 166)"]
                            [  
                              a [ class "navbar-brand logo", Route.href Route.NewArticle ]
                                    [ 
                                        svgLogo
                                    ]
                            , button [class "navbar-toggler navbar-dark", type_ "button", attribute "data-toggle" "collapse", attribute "data-target" "#navbarSupportedContent", attribute "aria-controls" "navbarSupportedContent", attribute "aria-expanded" "false", attribute "aria-label" "Toggle navigation"]
                              [ span [class "navbar-toggler-icon",style "color" "black"][]
                              ]     

                            , div [ class "collapse navbar-collapse", id "navbarSupportedContent", style "margin-right" "5vw" ]
                                [  
                                   ul [ class "nav navbar-nav pull-xs-right" ] <|
                                    viewMenu page treasury withdraws maybeViewer
                                ,  ul [ class "navbar-nav ml-md-auto" ] <|
                                     viewMenu2 transM page treasury withdraws maybeViewer
                                ]
                            ]


viewMenu : Page -> Maybe (List Treasury) -> Maybe (List Withdraw) -> Maybe Viewer -> List (Html msg)
viewMenu page treasury  withdraws maybeViewer  =
    let
        linkTo =
            navbarLink page
    in
    case maybeViewer of
        Just viewer ->
             menuItems page viewer 
                  
        Nothing ->
            [ 
            ]


viewMenu2 : Maybe Page.Exchange.Transactions.Model  -> Page -> Maybe (List Treasury) -> Maybe (List Withdraw) -> Maybe Viewer -> List (Html msg)
viewMenu2 transactionsMaybe page treasury  withdraws maybeViewer  =
    let
        linkTo =
            navbarLink page
    in
    case maybeViewer of
        Just viewer ->
            case treasury of 
                Just treasur ->
                    let
                        fund = List.head treasur
                    in
                    case fund of
                        Nothing ->
                            (menuItems2 transactionsMaybe page viewer Nothing withdraws) 
                        Just fnd ->
                            (List.append (menuItems2 transactionsMaybe page viewer treasury withdraws) 
                            [
                            ])
                Nothing ->
                    menuItems2  transactionsMaybe page viewer Nothing withdraws 
                  
        Nothing ->
            [ linkTo (Route.Login) [ text "Sign in" ]
            , linkTo (Route.Register) [ text "Sign up" ]
            ]

menuItems2 : Maybe Page.Exchange.Transactions.Model  -> Page ->  Viewer -> Maybe (List Treasury) -> Maybe (List Withdraw) -> List (Html msg)
menuItems2 transactionsMaybe page viewer treasury withdraws=
    let
        linkTo =
            navbarLink page
        username =
            Viewer.username viewer
        avatar =
            Viewer.avatar viewer
    in
    [
      linkTo Route.NewArticle [ i [ class "" ] [], span[style "font-weight" "bold"][text "EXCHANGE" ]]
    , linkTo Route.Withdraw [i [class ""] [], span[style "font-weight" "bold"][text "WALLET"]]
    , linkTo Route.Payments [ i [ class "" ] [], span[style "font-weight" "bold"][text "DEPOSIT/WITHDRAW"] ]
    , linkTo Route.Transaction [ i [ class "" ] [], span[style "font-weight" "bold"][text "HISTORY" ]]
    {--, linkTo Route.Prices [ i [ class "" ] [], span[style "font-weight" "bold"][text "Prices" ]]--}
    ,  dropDown transactionsMaybe treasury withdraws
    , li[classList [ ( "nav-item", True ), ("dropdown", True),( "active", isActive page Route.Profile )]]
       [
          a[class "nav-link", href "#pageSubmenu", id "navDropdown",attribute "role" "button", attribute "data-toggle" "dropdown", attribute "aria-haspopup" "true", attribute "aria-expanded" "false", style "padding-left" "20px", style "font-size" "1.25rem"]
            [div[style "display" "inline-block"][(Username.toHtml username), img[src "/images/user.svg",style "display" "inline-block", style "width" "30px", style "margin-left" "15px"][]]]

       ,  div[class "dropdown-menu", attribute "aria-labelledby" "navbarDropdown", style "font-size" "1.25rem"]
           [
              a[
                (Route.href (Route.Profile ))
               , class "dropdown_item" 
               , style "font-size" "1.25rem"
               ] [svgEdit, span[style "font-size" "1.25rem"][text "View Profile"]]
           ,  a[class "dropdown_item", Route.href Route.Logout, style "font-size" "1.25rem"]
                [svgLogout, span[style "font-size" "1.25rem"][text "Log Out"]]
           ]
       ]
    ]



menuItems : Page ->  Viewer -> List (Html msg)
menuItems page viewer=
    let
        linkTo =
            navbarLink page
        username =
            Viewer.username viewer

        avatar =
            Viewer.avatar viewer
    in
    [
    ]

logoIcon : Html msg
logoIcon =
    Html.img
        [ Asset.src Asset.logo2
        , class ""
        , alt ""
        , style "padding-right" "1vw"
        ]
        [span[style "color" "red"][text "BETA"]]

facebookIcon : Html msg
facebookIcon =
    Html.img
        [ Asset.src Asset.facebookIcon
        , style "width" "2vw"
        , style "height" "3vh"
        , alt ""
        , style "background-color" "white"
        ]
        []

googleplusIcon : Html msg
googleplusIcon =
    Html.img
        [ Asset.src Asset.googleplusIcon
        , style "width" "3vw"
        , style "height" "3vh"
        , alt ""
        ]
        []

twitterIcon : Html msg
twitterIcon =
    Html.img
        [ Asset.src Asset.twitterIcon
        , style "width" "2vw"
        , style "height" "3vh"
        , alt ""
        , style "background-color" "white"
        ]
        []

logoIcon2 : Html msg
logoIcon2 =
    Html.img
        [ Asset.src Asset.logo2
        , style "width" "6vw"
        , style "align" "right"
        , class "text-center"
        ]
        []

viewFooter : Html msg
viewFooter =
    footer []
        [ footer [ class "page-footer font-small blue pt-4" ,style "background-color" "white", style "width" "100%", style "background-color" "rgb(239, 239, 239)"]
          [ 
            div [class "container-fluid text-center text-md-left", style "margin-left" "50px"]
            [
              div[class "row  justify-content-between"]
              [
                
                div[class "col col-xs-2 col-sm-2 col-lg-1" ]
                  [
                   logoIcon2
                  ]
               , div[class "col-2 col-md-3 col-lg-2 col-xs-4 col-sm-4", style "margin-left" "2vw"]
                  [
                    span[class "footer_text_header"][text "Communication"]
                   ,   ul [class "list-unstyled", style "margin-top" "2vh"]
                        [
                          li [style "color" "white", style "margin-bottom" "1vh", class "row no-gutters"]
                          [
                           div[class "col-1 no-gutters", style "margin-top" "auto", style "margin-bottom" "auto", style "margin-right" "0.5vw"]
                           [
                            img[src "images/pin.svg", style "width" "100%", style "height" "50%"][]
                           ]
                          , div[class "col-10 no-gutters"]
                            [
                             span[class "footer_text"][text "ESTONIA Roseni 13, Tallinn Harju, 10111 GREECE L. V. Kon/nou 42, Athens, 11635"]
                            ]
                          ]
                         , li [style "color" "white", style "margin-bottom" "1vh", class "row no-gutters"]
                           [
                            div[class "col-1 no-gutters", style "margin-top" "auto", style "margin-bottom" "auto", style "margin-right" "0.5vw"]
                            [
                             img[src "images/email.svg", style "width" "100%", style "height" "50%"][]
                            ]
                          , div[class "col-10 no-gutters"]
                            [
                             span[class "footer_text"][text "info@greek-coin.gr"]
                            ]
                          ]
 
                         , li [style "color" "white", style "margin-bottom" "1vh", class "row no-gutters"]
                           [
                            div[class "col-1 no-gutters", style "margin-top" "auto", style "margin-bottom" "auto", style "margin-right" "0.5vw"]
                            [
                             img[src "images/mobile.svg", style "width" "100%", style "height" "50%"][]
                            ]
                          , div[class "col-10 no-gutters"]
                            [
                             span[class "footer_text"][text "+30 211 40 33 211"]
                            , br[][] 
                            , span[class "footer_text"][text "+30 6908 66 88 44"] 
                            ]
                          ]
 
                         ] 
                        ]

                , div[class "col col-sm-5 col-xs-5 col-md-3  col-lg"]
                  [
                      span[class "footer_text_header"][text "Details"]
                  ,   ul [class "list-unstyled", style "font-weight" "bold", style "margin-top" "2vh"]
                        [
                          li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.About] 
                            [ 
                                span[class "footer_text"][text "Services"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.About] 
                            [ 
                                span[class "footer_text"][text "Cryptocurrencies"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.About] 
                            [ 
                                span[class "footer_text"][text "User cases"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.About] 
                            [
                               span[class "footer_text"][ text "User cases"]
                            ]
                          ]
                        ]
                  ]
          , div[class "col col-sm-5 col-xs-5 col-md-4 col-lg"]
                  [
                      span[class "footer_text_header"][text "Legal"]  
                  ,   ul [class "list-unstyled", style "font-weight" "bold", style "margin-top" "2vh"]
                        [
                          li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.About] 
                             [
                                 span[class "footer_text"][ text "Services"]
                             ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.About] 
                            [ 
                                span[class "footer_text"][text "Cryptocurrencies"]
                            ]
                          ]
                         , li []
                          [ a [style "color" "rgba(68,68,68,1)",Route.href Route.About]
                            [ 
                                span[class "footer_text"][ text "User cases"]
                            ]
                          ]
                        ]
                  ]
                , div[class "col-3 col-sm-5 col-xs-5 col-md-5 col-lg-3", style "margin-right" "4vw"]
                  [
                     span[class "footer_text_header"][text "Newsletter"]
                   , div[class "input-group mb-3", style "margin-top" "20px", style "background-color" "white", style "border-radius" "160px", style "padding" "8px"]
                     [
                        input[type_ "text", class "form-control footer_text", placeholder  "Enter your email address", style "border-style" "none"][]
                      , div[class "input-group-append"]
                        [
                            button[class "btn btn-secondary", style "width" "45px", style "height" "45px", style "background-color" "rgb(0, 99, 166)", style "border-radius" "50px"] [img [style "width" "100%",src "images/send.svg",style "height" "100%" ,style "margin" "auto"][]]
                        ]
                     ]
                  ]
                , div[class "col col-lg-3"]
                  [
                   span[class "footer_text_header"][text "Social Media"]
                  ,p[style "margin-top" "2vh"][a [href "https://www.facebook.com/Greek-Coin-2010949822452284" ][img [src "images/facebook.svg", style "width" "1.5vw", style "margin-right" "1.5vw"][] ] , a[href "https://twitter.com/greekcoin1"][img[src "images/twitter.svg", style "width" "1.5vw", style "margin-right" "1.5vw"][]], img[src "images/linkedin.svg", style "width" "1.5vw"][]]
                  , div[class "row"]
                    [
                       {-- div[class "col no-gutters", style "max-width" "2vw"][img [src "images/certified.svg", style "width" "1.5vw", style "float" "left"][]]--}
                       div[class "col-10 no-gutters"]
                        [
                            span[style "font-weight" "bold"][text "Licensed from"]
                            
                        ,   p[][span[][text """European Union, Republic of Estonia
Financial Intelligence Unit
FRK001080 - Exchange services
FRK001195 - Wallet services"""]]
                       ]
                    ]  

                  ]
                ]
           ]
         , div[ style "color" "yellow",class "row", style "margin-top" "3vh"]
           [
             div[class "col"][]
           , div[class "col"]
              [
                 a[style "margin-right" "2.5vw", Route.href Route.Settings][text "Privacy, Terms & Conditions and Cookies Policy"]
              ,  a[Route.href Route.Article][text "KYC/AML"]
              ]
           , div[class "col"][]
           ]

          ]
        ]


navbarLink : Page -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive page route ) ], style "font-size" "1.25rem" ]
        [ a [ class "nav-link", Route.href route, style "font-size" "1.25rem" ] linkContent ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Prices, Route.Prices) ->
            True

        ( Login, Route.Login ) ->
            True

        ( Payments, Route.Payments) ->
            True

        ( Settings, Route.Settings ) ->
            True

        ( Transaction, Route.Transaction) ->
            True

        ( Verification, Route.Verification _ _) ->
            True

        ( Withdraw, Route.Withdraw) ->
            True

        ( Contact, Route.Contact) ->
            True

        ( Profile , Route.Profile ) ->
            True

        ( NewArticle, Route.NewArticle ) ->
            True

        _ ->
            False


{-| Render dismissable errors. We use this all over the place!
-}
viewErrors : msg -> List String -> Html msg
viewErrors dismissErrors errors =
    if List.isEmpty errors then
        Html.text ""
    else
        div
            [ class "error-messages"
            , style "position" "fixed"
            , style "top" "0"
            , style "background" "rgb(250, 250, 250)"
            , style "padding" "20px"
            , style "border" "1px solid"
            ]
        <|
            List.map (\error -> p [] [ text error ]) errors
                ++ [ button [ onClick dismissErrors ] [ text "Ok" ] ]
