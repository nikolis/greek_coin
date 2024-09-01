module Route exposing (Route(..), fromUrl, href, replaceUrl, routeToString)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Profile exposing (Profile)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string, (<?>))
import Username exposing (Username)
import Url.Parser.Query as Query 



-- ROUTING


type Route
    = Home
    | Root
    | Login
    | Register
    | Logout
    | Settings
    | Article 
    | Profile
    | NewArticle
    | EditArticlePre Int String
    | Prices
    | Transaction 
    | About
    | Contact
    | Payments
    | Withdraw
    | Company 
    | Faq
    | Cookies 
    | FeeTable 
    | Kyc 
    | Privacy
    | Terms 
    | Licenses
    | Verification (Maybe String) (Maybe String)


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Prices (s "prices")
        , Parser.map Login (s "login" )
        , Parser.map Register (s "register")
        , Parser.map Logout (s "logout")
        , Parser.map Settings (s "settings")
        , Parser.map About (s "about")
        , Parser.map Contact (s "contact")
        , Parser.map Profile (s "profile")
        , Parser.map Transaction (s "transaction")
        , Parser.map Article (s "article")
        , Parser.map NewArticle (s "exchange")
        , Parser.map Payments (s "payments")
        , Parser.map Company (s "company")
        , Parser.map Faq (s "faq")
        , Parser.map Withdraw (s "withdraw")

        , Parser.map Cookies (s "cookies")
        , Parser.map Licenses (s "licenses")
        , Parser.map FeeTable (s "feetable")
        , Parser.map Kyc (s "kyc")
        , Parser.map Privacy (s "privacy")
        , Parser.map Terms (s "terms")



        , Parser.map Verification (s "verification" <?> Query.string "type" <?> Query.string "parameter" )
        , Parser.map EditArticlePre (s "exchange" </> Parser.int </> Parser.string)
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    let
        _ = Debug.log "The url" url
    in
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    { url | path = url.path, fragment = url.fragment }
        |> Parser.parse parser



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Root ->
                    ["exchange"]

                Login  ->
                    [ "login" ]

                Register ->
                    [ "register"]

                Verification attr parameter->
                    case attr of 
                        Just str ->
                            case parameter of 
                                Just str2 ->
                                  ["verification", str, str2]
                                Nothing ->
                                  ["verification", str,""]
                        Nothing ->
                            case parameter of 
                                Just str2 ->
                                  ["verification", "", str2]
                                Nothing ->
                                  ["verification", "",""]


                Logout ->
                    [ "logout" ]

                Prices ->
                    ["prices"]

                Settings ->
                    [ "settings" ]
 
                About ->
                    [ "about" ]
                    
                Contact ->
                    [ "contact" ]

                Payments ->
                    [ "payments"]

                Transaction ->
                    [ "transaction"]

                Article ->
                    [ "article" ]

                Profile ->
                    [ "profile" ]
                    
                Withdraw ->
                    ["withdraw"]

                NewArticle ->
                    [ "exchange" ]

                EditArticlePre id ammount ->
                    [ "exchange", String.fromInt id, ammount]

                Faq ->
                    [ "faq"]

                Company ->
                    [ "company"]

                Cookies ->
                    [ "cookies"]

                FeeTable ->
                    [ "feetable"]

                Kyc ->
                    ["kyc"]

                Privacy ->
                    ["privacy"]

                Terms ->
                    ["terms"]

                Licenses ->
                    ["licenses"]

    in
    "/" ++ String.join "/" pieces
