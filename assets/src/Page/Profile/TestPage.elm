module Page.Profile.TestPage exposing (..)

import Api.Endpoint as Endpoint
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Loading
import Route
import Session exposing (Session)
import Task exposing (Task)
import Time
import Username exposing (Username(..) )
import Json.Encode as Encode
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Http.Legacy
import Html
import Api exposing (Cred)
import Animation exposing (px)
import Asset
import Api2.Data exposing (User, Address, decoderUser)
import Api2.Happy exposing (getBaseUrl)
import Page.Profile.Stepper as Stepper exposing (..)
import Api
import Route exposing (Route)
import Browser.Navigation as Navigat

type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , errors : List String
    , user : User
    , problems : List Problem
    , message : String
    , user_error : UserError
    , style : Animation.State
    , hover : Bool
    , stepperModel : Stepper.Model
    , viewModal : ViewModalStatus
    }


init : Session  -> ( Model, Cmd Msg )
init session =
    let
        maybeCred =
            Session.cred session
        (stepperModel , cmnd) = Stepper.init session
    in
    ( { session = session
      , stepperModel = stepperModel
      , hover = False
      , timeZone = Time.utc
      , errors = []
      , user = User "" "" "" "" "" "" "" "" "" "" "" "" (Address "" "" "" "") "" False 0
      , problems = []
      , message = ""
      , viewModal = Closed
      , style =
            Animation.style
                [ Animation.opacity 1.0
                ]
      , user_error = UserError [] [] [] (AddressError [] [] [] [])
      }
    , Cmd.batch
        [ Task.perform GotTimeZone Time.here
        , Task.attempt GotUser (fetchUser session)
        ]
    )

euCountries : List String
euCountries = 
    [
        "Austria"
    ,   "Greece"
    ,   "Belgium"
    ,   "Bulgaria"
    ,   "Croatia"
    ,   "Cyprus"
    ,   "Denmark"
    ,   "Czechia"
    ,   "Estonia"
    ,   "Finland"
    ,   "France"
    ,   "Germany"
    ,   "Hungary"
    ,   "Ireland"
    ,   "Italy"
    ,   "Latvia"
    ,   "Luxembourg"
    ,   "Malta"
    ,   "Netherlands"
    ,   "Poland"
    ,   "Portugal"
    ,   "Romania"
    ,   "Slovakia"
    ,   "Slovenia"
    ,   "Sweden"
    ,   "Spain"
    ]

fetchUser :  Session -> Task Http.Legacy.Error (User)
fetchUser  session =
    let
        request =
            Api.get Endpoint.user  (Session.cred session) decoderUser
    in
    Http.Legacy.toTask request

type ViewModalStatus = 
    Closed 
    | UnknownError String
    | Success String
    | Error
    | SessionExpired

type alias UserError =
    { email : List String
    , first_name : List String
    , last_name : List String
    , address :  AddressError
    }


type alias AddressError = 
    {
       address : List String
    ,  zip : List String
    ,  city : List String
    ,  country : List String
    }

addressErrorDecoder : Json.Decode.Decoder AddressError 
addressErrorDecoder = 
    Json.Decode.succeed AddressError
      |> optional "title" (Json.Decode.list string) []
      |> optional "zip" (Json.Decode.list string) []
      |> optional "city" (Json.Decode.list string) []
      |> optional "country" (Json.Decode.list string) []


userErrorDecoder2 : Json.Decode.Decoder UserError
userErrorDecoder2 =
    Json.Decode.succeed UserError
      |> optional "email" (Json.Decode.list string) []
      |> optional "first_name" (Json.Decode.list string) []
      |> optional "last_name" (Json.Decode.list string) []
      |> optional "address" addressErrorDecoder (AddressError [] [] [] [])


expectJson : (Result (DetailedError String) ( Http.Metadata, a ) -> msg) -> Json.Decode.Decoder a -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg (responseToJson decoder)


responseToJson : Json.Decode.Decoder a -> Http.Response String -> Result (DetailedError String) ( Http.Metadata, a )
responseToJson decoder responseString =
    resolve
        (\( metadata, body ) ->
            Result.mapError Json.Decode.errorToString
                (Json.Decode.decodeString (Json.Decode.map (\res -> ( metadata, res )) decoder) body)
        )
        responseString


resolve : (( Http.Metadata, body ) -> Result String a) -> Http.Response body -> Result (DetailedError body) a
resolve toResult response =
    case response of
        Http.BadUrl_ url ->
            Err (BadUrll url)

        Http.Timeout_ ->
            Err Timeoutt

        Http.NetworkError_ ->
            Err NetworkErrorr

        Http.BadStatus_ metadata body ->
            Err (BadStatuss metadata body)

        Http.GoodStatus_ metadata body ->
            Result.mapError (BadBodys metadata body) (toResult ( metadata, body ))


type DetailedError body
    = BadUrll String
    | Timeoutt
    | NetworkErrorr
    | BadStatuss Http.Metadata body
    | BadBodys Http.Metadata body String


type alias UploadCreds =
    { auth_header : String
    , date : String
    , hash : String
    , path : String
    }


addressEncoder : Address -> Encode.Value
addressEncoder address =
    Encode.object
    [ ("zip", Encode.string address.zip)
     ,("country", Encode.string address.country)
     ,("city", Encode.string  address.city)
     ,("title", Encode.string address.address)
    ]


userEncoder : User -> Encode.Value
userEncoder user =
    Encode.object
    [ ("user", userFieldsEncoder user)]


userFieldsEncoder : User ->  Encode.Value
userFieldsEncoder user =
    Encode.object
    [ ("email", Encode.string user.email)
     ,("first_name", Encode.string user.first_name)
     ,("last_name", Encode.string user.last_name)
     ,("address", addressEncoder user.address)
     ,("mobile", Encode.string user.mobile)
    ]


createUpdateCommand : Model -> Cmd Msg
createUpdateCommand model =
    Http.request
    {
     headers =
         case Session.cred (model.session) of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "PUT"
    , url = (getBaseUrl ++ "/api/v1/users")
    , body = Http.jsonBody (userEncoder model.user)
    , expect = expectJson  UploadCompleted userResponseDecoder
    , timeout = Nothing
    , tracker = Nothing
    }

userResponseDecoder : Json.Decode.Decoder UserResponse
userResponseDecoder = 
    Json.Decode.succeed UserResponse
      |> Json.Decode.Pipeline.required "user" decoderUser


type alias UserResponse = 
   {
       user : User
    } 

type Problem
    = InvalidEntry ValidatedField String
    | ServerError String


type ValidatedField
    = Username
    | Email
    | Password


fieldsToValidate : List ValidatedField
fieldsToValidate =
    [ Username
    , Email
    , Password
    ]


type Status a
    = Loading Username
    | LoadingSlowly Username
    | Loaded a
    | Failed Username

viewModal : Model -> Maybe (Html Msg)
viewModal model =
     case model.viewModal of 
        Closed ->
           case Stepper.viewModal model.stepperModel of
               Nothing ->
                  Nothing 
               Just  htmlView ->
                  Just (Html.map (\testMsg -> (StepperMsg testMsg)) htmlView)

        SessionExpired ->
              Just(
                  div[class "container"]
                  [
                   div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", style "width" "100%" , style "margin" "auto", style "padding" "10px 3px", onClick SessionExpiredMsg , class "btn btn-primary primary_button"]
                           [text "Session Expired" ]
                         ]
                     ]

                  ]
                )

        Error  ->
            Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text "Update error"]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col", style "text-align" "center"]
                          [
                              span[class "modal_message"][text "Please review the errors underneath apropriate fields"]
                          ]
                      ]
                  ,  div[class "row"]
                     [
                         div[class "col"]
                         [
                           button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModal, class "btn btn-primary primary_button"][text "OK"]
                         ] 
                     ]
                  ]
                )

        UnknownError theErr  ->
            Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text "Update error"]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col", style "text-align" "center"]
                          [
                              span[class "modal_message"][text theErr]
                          ]
                      ]
                  ,  div[class "row"]
                     [
                         div[class "col"]
                         [
                           button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModal, class "btn btn-primary primary_button"][text "OK"]
                         ] 
                     ]
                  ]
                )

        Success str ->
            Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text "Profile Update"]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_message"][text "Your personal informations have been successfully updated"]
                          ]
                      ]
                  ,  div[class "row"]
                     [
                         div[class "col"]
                         [
                           button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModal, class "btn btn-primary primary_button"][text "OK"]
                         ]
                     ]
                  ]
                )


view : Model ->  Html Msg
view model =
    let
        emailError = List.foldl (\item existing -> item ++ " " ++existing) "" model.user_error.email
        firstNameError = List.foldl (\item existing -> item ++ " " ++existing) "" model.user_error.first_name
        lastNameError = List.foldl (\item existing -> item ++ " " ++existing) "" model.user_error.last_name
        addressError = List.foldl (\item existing -> item ++ " " ++existing) "" model.user_error.address.address
        zipError = List.foldl (\item existing -> item ++ " " ++existing) "" model.user_error.address.zip
        cityError = List.foldl (\item existing -> item ++ " " ++existing) "" model.user_error.address.city
        countryError = List.foldl (\item existing -> item ++ " " ++existing) "" model.user_error.address.country
    in
              div[class "col"]
              [
                
                  div [class "row"]
                  [
                      div[class "col-lg"]
                      [
                          div[class "row"]
                          [
                            div[class "col"]
                            [
                                img[src "/images/user.svg",style "width" "2vw", style "margin-right" "1vw"][]
                            ,   span[style "color" "rgba(0,99,166,1)", style "font-size" "1.5rem" , style "font-weight" "bold"][text "Personal Details"]
                            ]
                          ]
                      ,   div[class "row", style "margin-top" "1vh"]
                          [
                              div[class "col"]
                              [
                                  span[][text "Please complete all the fields in order to start trading."]
                              ]
                          ]
                      ,   div[class "row", style "margin-top" "4vh", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
                          [
                            div[class "col", style "padding" "4px"]
                            [
                              label [class "form-control", style "border" " 0px solid white"][text "Email Address"]
                            , input [class "form-control", onInput EmailCh,value model.user.email, style "border" " 0px solid white", style "font-weight" "bold"] []
                            , small[class "text-danger"][text emailError]
                            ]
                          , div[class "col-2"]
                            [
                               img[][]
                            ]
                          ]
                     ,   div[class "row", style "margin-top" "2vh"]
                          [
                            div[class "col", style "padding" "4px", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
                            [
                              label [class "form-control", style "border" " 0px solid white"][text "First Name"]
                            , input [class "form-control" ,onInput FirstName ,value model.user.first_name, style "border" " 0px solid white", style "font-weight" "bold"] []
                            , small[class "text-danger"][text firstNameError]
                            ]
                          , div[class "col", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px", style "margin-left" "1vw"]
                            [
                              label [class "form-control", style "border" " 0px solid white"][text "Last Name"]
                            , input [class "form-control", onInput LastName , value model.user.last_name, style "border" " 0px solid white", style "font-weight" "bold"] []
                            , small[class "text-danger"][text lastNameError]
                            ]
                          ]
                     ,   div[class "row", style "margin-top" "2vh", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
                          [
                            div[class "col", style "padding" "4px"]
                            [
                              label [class "form-control", style "border" " 0px solid white"][text "Address and number"]
                            , input [class "form-control",onInput AddressCh ,value model.user.address.address , style "border" " 0px solid white", style "font-weight" "bold"] []
                            , small[class "text-danger"][text addressError]
                            ]
                          ]
                     ,   div[class "row", style "margin-top" "2vh"]
                          [
                            div[class "col", style "padding" "4px", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
                            [
                              label [class "form-control", style "border" " 0px solid white"][text "City"]
                            , input [class "form-control" ,onInput City ,value model.user.address.city, style "border" " 0px solid white", style "font-weight" "bold"] []
                            , small[class "text-danger"][text cityError]
                            ]
                          , div[class "col", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px", style "margin-left" "15px"]
                            [
                               label [class "form-control", style "border" " 0px solid white"][text "Postal Code"]
                            , input [class "form-control", onInput Zip, value model.user.address.zip , style "border" " 0px solid white", style "font-weight" "bold"] []
                            , small[class "text-danger"][text zipError]
                            ]
                          ]
                     ,   div[class "row", style "margin-top" "2vh", style "border" "2px solid rgb(239, 239, 239)", style "border-radius" "15px"]
                          [
                            div[class "col", style "padding" "4px"]
                            [
                              label [class "form-control", style "border" " 0px solid white"][text "Country"]
                            , select [onInput Country, class "form-control", value  model.user.address.country, style "font-weight" "bold"]
                              (option[][] :: (List.map (\entry -> (option[value entry, class "form-control"][span[style "font-weight" "bold"][text entry]])) euCountries))
                            {--, input [class "form-control", onInput Country, value model.user.address.country , style "border" " 0px solid white", style "font-weight" "bold"] []--}
                            , small[class "text-danger"][text countryError]
                            ]
                          ]
                     ,  div [class "row", style "margin-top" "45px"]
                        [
                         div[class "col d-flex flex-row-reverse"]
                          [
                             button [class "p-2",type_ "button", style "width" "30%" , style "margin" "auto", style "padding" "10px 3px", onClick SendUpload, class "btn btn-primary", style "border-radius" "25px", style "font-size" "1.35rem", style "font-weight" "bold", style "background-color" "rgb(0, 99, 166)" , style "text-shadow" "1.5px 0 white", style "letter-spacing" "1px"][text "Update"]
                          ]
                        ]

                      ]
                  ,   div[class "col-lg"]
                      [
                          Html.map (\stepperMsg -> (StepperMsg stepperMsg)) (Stepper.view model.stepperModel)
                      ]
                  ]
               
               , div [class "row", style "margin-top" "45px"]
                [
                    div[class "col-3"][]
                ,   div[class "col"]
                    [
                     {-- button [type_ "button", style "width" "30%" , style "margin" "auto", style "padding" "10px 3px", onClick SendUpload, class "btn btn-primary", style "border-radius" "25px", style "font-size" "1.35rem", style "font-weight" "bold", style "background-color" "rgb(0, 99, 166)" , style "text-shadow" "1.5px 0 white", style "letter-spacing" "1px"][text "Update"]--}
                    ]
                ]
              ]
-- UPDATE


type Msg  =  
    GotTimeZone Time.Zone
    | GotSession Session
    | GotUser (Result Http.Legacy.Error User)
    | FirstName String
    | LastName String
    | Zip String
    | Country String
    | City String
    | AddressCh String
    | EmailCh String
    | UploadCompleted (Result (DetailedError String) ( Http.Metadata, UserResponse))
    | SendUpload
    | MobileCh String
    | Animate Animation.Msg
    | FadeInFadeOut
    | StepperMsg Stepper.Msg 
    | CloseModal
    | SessionExpiredMsg

type ErrorDetailed
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Http.Metadata String
    | BadBody String


expectStringDetailed : (Result ErrorDetailed ( Http.Metadata, String ) -> msg) -> Http.Expect msg
expectStringDetailed msg =
    Http.expectStringResponse msg convertResponseString


convertResponseString : Http.Response String -> Result ErrorDetailed ( Http.Metadata, String )
convertResponseString httpResponse =
    case httpResponse of
        Http.BadUrl_ url ->
            Err (BadUrl url)

        Http.Timeout_ ->
            Err Timeout

        Http.NetworkError_ ->
            Err NetworkError

        Http.BadStatus_ metadata body ->
            Err (BadStatus metadata body)

        Http.GoodStatus_ metadata body ->
            Ok ( metadata, body )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SessionExpiredMsg ->
           (model, Cmd.batch [Api.clearLogInfo, Navigat.load (Route.routeToString Route.Login)])

        CloseModal ->
            ({ model | viewModal = Closed}, Cmd.none)
        StepperMsg theMsg ->
          let
              (stepperM, cmnd) = Stepper.update theMsg model.stepperModel
          in
          ({model | stepperModel = stepperM}, Cmd.map(\stepMs -> (StepperMsg stepMs)) cmnd)

        FadeInFadeOut ->
            ( { model
                | style =
                    Animation.interrupt
                        [Animation.loop
                            [ Animation.toWith (Animation.speed { perSecond = 1  })
                              [ Animation.opacity 0
                              ]
                           , Animation.toWith (Animation.speed { perSecond = 1  })
                              [ Animation.opacity 1
                              ]
                          ]
                        ]
                        model.style
              }
            , Cmd.none
            )

        Animate animMsg ->
            ( { model
                | style = Animation.update animMsg model.style
              }
            , Cmd.none
            )

        GotUser (Ok new_user) ->
            let
                (stepperModel, cmnd)  = Stepper.update (Stepper.GotUser new_user) model.stepperModel 
            in
            ({model | user = new_user, stepperModel = stepperModel}, Cmd.none)

        GotUser (Err err) ->
            let
                _ = Debug.log "the ret error: " (Debug.toString err)
            in
            (model, Cmd.none)

        UploadCompleted (Ok new_user) ->
            let
                (meta, message) = new_user
            in
            ({model | viewModal = Success ""}, Cmd.none)


        UploadCompleted (Err httpError) ->
            case httpError of
                BadStatuss metadata body ->
                    let
                        result = (Json.Decode.decodeString userErrorDecoder2 body)
                    in
                    case result of
                        Err error ->
                            case metadata.statusCode of
                                401 ->
                                  ({model | viewModal = SessionExpired }, Cmd.none)
                                _ ->
                                  ({model | viewModal = UnknownError "Unknown error"}, Cmd.none)
                        Ok userError ->
                            case metadata.statusCode of 
                                401 ->
                                   ({model | user_error = userError, viewModal = SessionExpired}, Cmd.none)
                                _ ->
                                   ({model | user_error = userError, viewModal = Error}, Cmd.none)

                BadUrll url ->
                    ( model, Cmd.none)

                Timeoutt ->
                    ( {model | viewModal = UnknownError "The server failed to respond in time"}, Cmd.none)

                NetworkErrorr ->
                    ( {model | viewModal = UnknownError "The server is unreachable"}, Cmd.none)

                BadBodys a b c ->
                    ( {model | viewModal = Success ""}, Cmd.none)

        GotTimeZone tz ->
            ( { model | timeZone = tz }, Cmd.none )

        GotSession session ->
            ( { model | session = session }
            , Route.replaceUrl (Session.navKey session) Route.Home
            )

        FirstName name ->
            let
                user_old = model.user
                user = {user_old| first_name = name}
            in
            ({model| user = user}, Cmd.none)

        MobileCh mobile ->
            let
                user_old = model.user
                user = {user_old | mobile = mobile}
            in
            ({model | user = user}, Cmd.none)
        LastName name ->
            let
                user_old = model.user
                user = {user_old | last_name = name}
            in
            ({model | user = user}, Cmd.none)
        EmailCh email ->
            let
                user_old = model.user
                user = {user_old | email = email}
            in
            ({model | user = user}, Cmd.none)
        Zip zip ->
            let
                old_address = model.user.address
                old_user = model.user
                address = {old_address | zip = zip}
                user = {old_user | address = address}
            in
            ({model | user = user}, Cmd.none)

        City city ->
            let
                old_address = model.user.address
                old_user = model.user
                address = {old_address | city = city}
                user = {old_user | address = address}
            in
            ({model | user = user}, Cmd.none)

        Country country ->
            let
                old_address = model.user.address
                old_user = model.user
                address = {old_address | country = country}
                user = {old_user | address = address}
            in
            ({model | user = user}, Cmd.none)

        AddressCh street ->
            let
                old_address = model.user.address
                old_user = model.user
                address = {old_address | address = street}
                user = {old_user | address = address}
            in
            ({model | user = user}, Cmd.none)


        SendUpload ->
            (model, createUpdateCommand model)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [
      Session.changes GotSession (Session.navKey model.session)
    , Animation.subscription Animate [ model.style ]
    ]
