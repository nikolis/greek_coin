module Page.Profile.Stepper exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick, preventDefaultOn, on)
import Html.Attributes exposing (class, src, attribute, multiple)
import Session exposing (Session)
import Svg exposing (svg, ellipse, g, metadata, defs, text_, tspan)
import Svg.Attributes exposing (height, width, style, ry, id , cy, rx, cx, transform, version, viewBox, y, x, type_)
import File exposing (File)
import File.Select as Select
import Json.Encode as Encode
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable)
import Bytes exposing (Endianness(..))
import Bytes exposing (Bytes)
import Task exposing (Task)
import SHA256 as SHA
import Http.Legacy
import Json.Encode as Encode
import Json.Decode exposing (list, string, Decoder, field, map5, decodeString, errorToString, nullable)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Http
import Http.Detailed
import Api
import Api2.Data exposing (User, Address, decoderUser)
import Api2.Happy exposing (getBaseUrl)
import Loading
import Asset
import List.Extra as LE
import File.Select as Select
import Api
import Route exposing (Route)
import Browser.Navigation as Navigat


type alias Model = 
    {
      numb : Int
    , step : Maybe Step
    , hover : Bool
    , files : List File
    , user : Maybe User
    , currentFileHash : String
    , session : Session
    , currentFile : Maybe File
    , uploadingPhotoIdFront : UploadingStatus
    , uploadingPhotoIdBack : UploadingStatus
    , uploadingPhotoOfi : UploadingStatus
    , uploadingPhotoSelfie : UploadingStatus
    , message : String
    , user_error : UserError
    , currentFileUrl : String
    , complete : List (UploadingStatus)
    , viewModal : ViewModalStatus
    }

init : Session -> (Model, Cmd Msg)
init session = 
    let
        md = 
            {
              numb = 1
            , currentFile = Nothing

            , step = Nothing
            , hover = False
            , files = [] 
            , user = Nothing
            , message = ""
            , currentFileHash = ""
            , session = session
            , uploadingPhotoIdFront = Initial
            , uploadingPhotoIdBack = Initial
            , uploadingPhotoOfi = Initial
            , uploadingPhotoSelfie = Initial
            , user_error = UserError "" "" "" "" "" ""  ""
            , currentFileUrl = "http://ssl.gstatic.com/accounts/ui/avatar_2x.png"
            , complete = []
            , viewModal = Closed
            }

    in
    (md, Cmd.none)    

type ViewModalStatus = 
    Closed 
    | SessionExpired

viewModal : Model -> Maybe (Html Msg)
viewModal model =
     case model.viewModal of 
        Closed ->
            Nothing

        SessionExpired ->
              Just(
                  div[class "container"]
                  [
                    div[class "row justify-content-center"]
                     [

                        div[class "col-4"]
                         [
                           button [type_ "button", Html.Attributes.style "width" "100%" , Html.Attributes.style "margin" "auto", Html.Attributes.style "padding" "10px 3px", onClick SessionExpiredMsg , class "btn btn-primary primary_button"]
                           [text "Log In" ]
                         ]
                     ]

                  ]
                )




getInitialState : User -> Step -> UploadingStatus 
getInitialState user step = 
  case step of 
      First ->
          if (String.isEmpty user.idPickFront) then 
             Initial
          else if not (String.isEmpty user.idPickFrontComment) then
             AdminComments
          else
             Uploaded
      Second ->
           if (String.isEmpty user.idPickBack) then 
             Initial
          else if not (String.isEmpty user.idPickBackComment) then
             AdminComments
          else
             Uploaded
  
      Third ->
          if (String.isEmpty user.ofiBillFile) then 
             Initial
          else if not (String.isEmpty user.ofiBillFileComment) then
             AdminComments
          else
             Uploaded
      Forth ->
          if (String.isEmpty user.selfiePic) then 
             Initial
          else if not (String.isEmpty user.selfiePicComment) then
             AdminComments
          else
             Uploaded

getNextStep : Maybe User -> Maybe Step
getNextStep mUser  = 
    case mUser of 
        Nothing ->
            Nothing
        Just user ->
          if (String.isEmpty user.idPickFront) then 
             Just First

          else if not (String.isEmpty user.idPickFrontComment) then
             Just First

          else if (String.isEmpty user.idPickBack) then 
             Just Second

          else if not (String.isEmpty user.idPickBackComment) then
             Just Second

          else if (String.isEmpty user.ofiBillFile) then 
             Just Third

          else if not (String.isEmpty user.ofiBillFileComment) then
             Just Third

          else if  (String.isEmpty user.selfiePic) then 
             Just Forth

          else if not (String.isEmpty user.selfiePicComment) then
             Just Forth

          else
             Nothing

decoderUploadCreds : Json.Decode.Decoder UploadCreds
decoderUploadCreds =
    Json.Decode.succeed UploadCreds
    |> Json.Decode.Pipeline.required "auth_header" Json.Decode.string
    |> Json.Decode.Pipeline.required "date" Json.Decode.string
    |> Json.Decode.Pipeline.required "hash" Json.Decode.string
    |> Json.Decode.Pipeline.required "path" Json.Decode.string

filesDecoder : Json.Decode.Decoder File
filesDecoder =
  Json.Decode.at ["target","files"] (File.decoder)

getPicPathForUser : User -> Maybe String
getPicPathForUser user =
    let
      parts = String.split "@" user.email
    in
      List.head parts


type alias UploadCreds =
    { auth_header : String
    , date : String
    , hash : String
    , path : String
    }


getUploadCreds :  String -> String -> Model -> String -> Cmd Msg
getUploadCreds  path file_hash model fileName=
    let
        url = (getBaseUrl ++ "/api/v1/users/immage")
        body =
            Encode.object [ ( "file_hash", Encode.string file_hash )
                          , ("path", Encode.string path)
                          ]
                |> Http.jsonBody
    in
    Http.request
    {
     headers =
         case Session.cred (model.session) of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "POST"
    , url = url
    , body =  body
    , expect = Http.Detailed.expectJson  (GotUploadCreds fileName) decoderUploadCreds
    , timeout = Nothing
    , tracker = Nothing
    }

    {--Api.uploadImmageUrl (Session.cred session) body decoderUploadCreds--}

uploadToS3 : File -> UploadCreds-> String ->Cmd Msg
uploadToS3  file  creds pic =
   let
        the_url = "https://greekcoinuserimages.s3.amazonaws.com" ++ creds.path
        request = Http.request
          { method = "PUT"
          , headers =
              [ Http.header "X-Amz-Content-Sha256" creds.hash
              , Http.header "X-Amz-Date" creds.date
              , Http.header "Authorization" creds.auth_header
              , Http.header "Access-Control-Allow-Origin" "*"
              , Http.header "Content-Type" "application/x-www-form-urlencoded"
              ]
          , url = the_url
          , body =   Http.fileBody  file
          , expect = expectStringDetailed (UploadResult pic)
          , timeout = Nothing
          , tracker = Nothing
          }
   in
   request

createUpdateCommandProfile : Model -> String -> String-> Cmd Msg
createUpdateCommandProfile model url pic=
    Http.request
    {
     headers =
         case Session.cred (model.session) of
             Just cred ->
                 [ Api.credHeader cred]
             Nothing ->
                 []
    , method = "PUT"
    , url =(getBaseUrl ++  "/api/v1/users")
    , body = Http.jsonBody (profilePicEncoder2 url pic)
    , expect = expectJson  UploadCompleted string
    , timeout = Nothing
    , tracker = Nothing
    }

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



decoderViewUrl : Json.Decode.Decoder ViewUrl
decoderViewUrl =
    Json.Decode.succeed ViewUrl
    |> Json.Decode.Pipeline.required "url" Json.Decode.string

getViewUrl : Session -> String -> Http.Legacy.Request ViewUrl
getViewUrl session path =
    let
        body =
            Encode.object [ ("path", Encode.string path)]
            |> Http.jsonBody
    in
    Api.getViewUrl (Session.cred session) body decoderViewUrl

profilePicEncoder : String -> String -> Encode.Value
profilePicEncoder picture path =
    Encode.object
    [ (picture, Encode.string path)
    , ((picture++"_comment"), Encode.string "")
    ]


profilePicEncoder2 : String -> String->Encode.Value
profilePicEncoder2 path picture =
    Encode.object
    [ ("user", profilePicEncoder picture path)]

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

responseToJson : Json.Decode.Decoder a -> Http.Response String -> Result (DetailedError String) ( Http.Metadata, a )
responseToJson decoder responseString =
    resolve
        (\( metadata, body ) ->
            Result.mapError Json.Decode.errorToString
                (Json.Decode.decodeString (Json.Decode.map (\res -> ( metadata, res )) decoder) body)
        )
        responseString

type alias UserError =
    { email :  String
    , first_name :  String
    , last_name : String
    , address : String
    , zip : String
    , city : String
    , country : String
    }


userErrorDecoder2 : Json.Decode.Decoder UserError
userErrorDecoder2 =
    Json.Decode.succeed UserError
      |> optional "email" string ""
      |> optional "first_name" string ""
      |> optional "last_name" string ""
      |> optional "title" string ""
      |> optional "zip" string ""
      |> optional "city" string ""
      |> optional "country" string ""


type UploadingStatus
  = Initial
  | Uploading
  | Uploaded
  | AdminComments
  | Failed

type Step =
    First 
    | Second 
    | Third
    | Forth

type ErrorDetailed
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Http.Metadata String
    | BadBody String

type DetailedError body
    = BadUrll String
    | Timeoutt
    | NetworkErrorr
    | BadStatuss Http.Metadata body
    | BadBodys Http.Metadata body String

expectJson : (Result (DetailedError String) ( Http.Metadata, a ) -> msg) -> Json.Decode.Decoder a -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg (responseToJson decoder)

type alias ViewUrl =
    { url : String }

type Msg = 
    ChangeStepTo Step 
    | DragEnter
    | DragLeave
    | GotFiles2 File (List File)
    | GotFiles File
    | LoadedBytes Bytes
    | GotUploadCreds String (Result (Http.Detailed.Error String) (Http.Metadata, UploadCreds))
    | UploadResult String (Result ErrorDetailed ( Http.Metadata, String))
    | UpdatePicture String String
    | UploadCompleted (Result (DetailedError String) ( Http.Metadata, String ))
    | GotViewUrl String  (Result Http.Legacy.Error ViewUrl)
    | GotUser User
    | FileS
    | SessionExpiredMsg

selectZip : Cmd Msg
selectZip =
  Select.file ["application/jpg"] GotFiles

getPercent : Model -> Maybe (Float, Float)
getPercent model = 
    case model.user of
        Nothing ->
            Just(4, 4)
        Just user ->
            let
                list =  [ (user.idPickFront, user.idPickFrontComment), (user.idPickBack, user.idPickBackComment)
                        , (user.ofiBillFile, user.ofiBillFileComment), (user.selfiePic, user.selfiePicComment)
                        ]
                number = List.foldl (\ (pic, comm) acc ->
                                      let
                                          _ = Debug.log "asdf" pic
                                      in 
                                       if(String.isEmpty pic) then
                                          acc - 1
                                       else  if (not (String.isEmpty comm)) then 
                                          acc - 1
                                       else 
                                          acc
                                      ) 4 list
                _ = Debug.log "sadfbumb" number
            in
            Just (number,4)
        
{--  case List.length model.complete of 
      0 ->
          Nothing
      _ ->
        let
          sum = List.foldl (\status count -> 
              case status of 
                  Uploaded ->
                      count + 1
                  _ ->
                      count
                  ) 0 model.complete
        in
        Just (sum, toFloat (List.length model.complete))--}




update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of
        FileS ->
           (model, selectZip)

        SessionExpiredMsg ->
           (model, Cmd.batch [Api.clearLogInfo, Navigat.load (Route.routeToString Route.Login)])

        GotUser user ->
            let
                state1 = getInitialState user First
                state2 = getInitialState user Second
                state3 = getInitialState user Third
                state4 = getInitialState user Forth
                newComplete = model.complete ++ [state1,state2,state3,state4]
                currentStep = getNextStep (Just user)
            in
            ({model | step = currentStep, user = Just user,complete = newComplete, uploadingPhotoIdFront = state1, uploadingPhotoIdBack = state2, uploadingPhotoOfi = state3, uploadingPhotoSelfie = state4}, Cmd.none)
        ChangeStepTo step ->
            ({ model| step = Just step}, Cmd.none)

        DragEnter ->
          ( { model | hover = True }
          , Cmd.none
          )

        DragLeave ->
          ( { model | hover = False }
          , Cmd.none
          )

        GotViewUrl pic (Err err) ->
            let
                _=Debug.log "error getint url:" (Debug.toString err)
            in
            ({ model| uploadingPhotoIdFront = AdminComments }, Cmd.none)

        GotViewUrl pic (Ok okUrl) ->
            let
                _=Debug.log "the url" okUrl.url
            in
            case pic of
                        "id_pic_front" ->
                             let
                                 newUser = case model.user of
                                     Just user ->
                                         Just {user | idPickFrontComment = "", idPickFront = okUrl.url}
                                     Nothing ->
                                         Nothing

                                 mdNew = { model | currentFileUrl = okUrl.url, uploadingPhotoIdFront = Uploaded, user = newUser}
                                 mdLat = {mdNew | step = getNextStep newUser}
                             in
                             (mdLat, Cmd.none)

                        "id_pic_back" ->
                             let
                                 newUser = case model.user of
                                     Just user ->
                                         Just {user | idPickBackComment = "", idPickBack = okUrl.url}
                                     Nothing ->
                                         Nothing
                                 mdNew = {model | currentFileUrl = okUrl.url, uploadingPhotoIdBack = Uploaded,user = newUser}
                                 mdLat = {mdNew | step = getNextStep newUser}

                             in
                             (mdLat, Cmd.none)

                        "ofi_bill_file" ->
                             let
                                 newUser = case model.user of
                                     Just user ->
                                         Just {user | ofiBillFileComment = "", ofiBillFile = okUrl.url}
                                     Nothing ->
                                         Nothing

                                 mdNew = {model | currentFileUrl = okUrl.url, uploadingPhotoOfi = Uploaded, user = newUser}
                                 mdLat = {mdNew | step = getNextStep newUser}
                             in
                             (mdLat, Cmd.none)

                        "selfie_pic" ->
                             let
                                 newUser = case model.user of
                                     Just user ->
                                         Just {user | selfiePicComment = "", selfiePic = okUrl.url}
                                     Nothing ->
                                         Nothing
                                 mdNew = {model | currentFileUrl = okUrl.url, uploadingPhotoSelfie = Uploaded, user = newUser}
                                 mdLat = {mdNew | step = getNextStep newUser}
                             in
                             (mdLat, Cmd.none)

                        _ ->
                            (model, Cmd.none)

        UpdatePicture url pic->
            case model.user of 
                Just user ->
                    case getPicPathForUser user of
                        Just path ->
                             (model, Cmd.batch[(Http.Legacy.send (GotViewUrl pic) (getViewUrl model.session ("users/nikolis/"++pic))),
                             createUpdateCommandProfile model ("/users/"++ path ++ "/"++pic) pic ])
                        Nothing ->
                             (model, Cmd.none)
                Nothing ->
                    (model, Cmd.none)

        UploadResult pic (Err err)->
            let
               _ = Debug.log "error while uploading" (Debug.toString err)
            in
            (model, Cmd.none)

        UploadResult pic (Ok sth) ->
            case model.user of 
                Just user ->
                    let
                       (data, res ) = sth
                       user_old = user
                       new_user = {user_old | idPickFront = data.url}
                    in
                    update (UpdatePicture data.url pic)  {model | user = Just new_user}
                Nothing ->
                    (model, Cmd.none)

        LoadedBytes content ->
            case model.user of
                Just user ->
                    let
                       shaHex = SHA.toHex (SHA.fromBytes content)
                    in
                    case getPicPathForUser user of
                        Just path ->
                            case model.step of
                                Nothing ->
                                    (model, Cmd.none)
                                Just step ->
                                    let
                                     (md, fileName) =
                                       case step of
                                           First ->
                                              ({model | uploadingPhotoIdFront= Uploading}, "id_pic_front")
                                           Second ->
                                              ({model | uploadingPhotoIdBack = Uploading},"id_pic_back")
                                           Third ->
                                              ({model | uploadingPhotoOfi = Uploading }, "ofi_bill_file")
                                           Forth ->
                                              ({model | uploadingPhotoSelfie = Uploading}, "selfie_pic")
                                    in
                                    ({model| currentFileHash = shaHex}, getUploadCreds ("/users/"++ path ++ "/"++fileName) shaHex model fileName)  
                                    
                                      {--(Http.Legacy.send (GotUploadCreds fileName) (getUploadCreds model.session ("/users/"++ path ++ "/"++fileName) shaHex)))--}
                        Nothing ->
                            (model, Cmd.none)     
                Nothing ->
                    (model, Cmd.none)

        GotUploadCreds pic (Err httpError) ->
            case httpError of
                Http.Detailed.BadStatus metadata body ->
                    let
                        result = (Json.Decode.decodeString userErrorDecoder2 body)
                    in
                    case result of
                        Err error ->
                            case metadata.statusCode of
                                401 ->
                                  ({model | viewModal = SessionExpired }, Cmd.none)
                                _ ->
                                  (model, Cmd.none)
                        Ok userError ->
                            case metadata.statusCode of 
                                401 ->
                                   ({model |  viewModal = SessionExpired}, Cmd.none)
                                _ ->
                                   (model, Cmd.none)

                Http.Detailed.BadUrl url ->
                    ( model, Cmd.none)

                Http.Detailed.Timeout ->
                    ( model, Cmd.none)

                Http.Detailed.NetworkError ->
                    ( model, Cmd.none)

                Http.Detailed.BadBody a b c ->
                    ( model, Cmd.none)

        GotUploadCreds pic (Ok (metadata, upCreds)) ->
            let
               _ = Debug.log "succees" (Debug.toString upCreds)
            in
            case model.currentFile of
                Just file ->
                    let
                       _ = Debug.log "the file is: " (File.name file)
                    in
                    case pic of
                        "id_pic_front" ->
                            ({model| uploadingPhotoIdFront = Uploading }, (uploadToS3 file upCreds pic))
                        "id_pic_back" ->
                            ({model| uploadingPhotoIdBack = Uploading }, (uploadToS3 file upCreds pic))
                        "ofi_bill_file" ->
                            ({model| uploadingPhotoOfi = Uploading }, (uploadToS3 file upCreds pic))
                        "selfie_pic" ->
                            ({model| uploadingPhotoSelfie = Uploading }, (uploadToS3 file upCreds pic))
                        _ ->
                            (model, Cmd.none)

                Nothing ->
                    ( model, Cmd.none)

        UploadCompleted (Ok new_user) ->
            let
                _ = Debug.log "the user ret: " (Debug.toString new_user)
                (meta, message) = new_user
            in
            ({model | message = message}, Cmd.none)


        UploadCompleted (Err httpError) ->
            case httpError of
                BadStatuss metadata body ->
                    let
                        result = (Json.Decode.decodeString userErrorDecoder2 body)
                    in
                    case result of
                        Err error ->
                            Debug.log (Json.Decode.errorToString error)
                            ( model, Cmd.none)
                        Ok userError ->
                            let
                                _ = Debug.log "the errors: " (Debug.toString userError)
                            in
                            ({model | user_error = userError }, Cmd.none)

                BadUrll url ->
                    ( model, Cmd.none)

                Timeoutt ->
                    ( model, Cmd.none)

                NetworkErrorr ->
                    ( model, Cmd.none)

                BadBodys a b c ->
                    ( model, Cmd.none)

        GotFiles  file  ->
            let
                _ = Debug.log "here" "here"
            in
             ( { model
                   | files = [file]
                   , currentFile = Just file
                   } ,Task.perform LoadedBytes (File.toBytes file))


        GotFiles2 file files ->
            let
                theFile = List.head files
            in
            case theFile of 
                Just file2 ->
                    let
                         _ = Debug.log "di.e" "file"
                    in
                    (model, Task.perform LoadedBytes (File.toBytes file2))

                Nothing ->
                    let
                        _ = Debug.log "dadads " "no file"
                    in
                 ( { model
                   | files = file :: files
                   , hover = False
                   , currentFile = Just file
                   } ,Task.perform LoadedBytes (File.toBytes file))


viewHeader : Model -> Html Msg 
viewHeader model = 
       case getPercent model of
           Just (somth, somth2) ->
             let
                 percent = (somth/somth2)*100
                 stringRep =( String.fromFloat percent)
                 _ = Debug.log "string rep" stringRep
             in
                case stringRep of
                    "100" ->
                        div[]
                        [
                            span[][text "You have successfully uploaded your documents. Our team will review and update your account soon."]
                        ,     div[class "progress",Html.Attributes.style "border-radius" "50px", Html.Attributes.style "margin-top" "20px", Html.Attributes.style "margin-bottom" "20px"]
                                     [
                                         div[class "progress-bar",Html.Attributes.style "background-color" "rgba(158,158,158,1)", attribute "role" "progressbar", Html.Attributes.style "width"  (stringRep ++ "%"), attribute "aria-valuenow" stringRep, attribute "aria-valuemax" "100"][]
                                     ]    

                        ]
                    _ ->
                     div[class "progress",Html.Attributes.style "border-radius" "50px", Html.Attributes.style "margin-top" "20px", Html.Attributes.style "margin-bottom" "20px"]
                     [
                         div[class "progress-bar",Html.Attributes.style "background-color" "rgba(158,158,158,1)", attribute "role" "progressbar", Html.Attributes.style "width"  (stringRep ++ "%"), attribute "aria-valuenow" stringRep, attribute "aria-valuemax" "100"][]
                     ]    
           Nothing ->
               div[][]



view : Model -> Html Msg
view model = 
  case model.user of
    Nothing ->
        div[class "container-xl"][Loading.icon]
    Just user ->
        case user.clearanceLevel == 0 of
            True ->
                 div[class "container-md"]
                 ([
                  ] ++ (viewMainBody model))

            False ->
                case user.clearanceLevel > 0 of
                    False ->
                         div[class "container-md"]
                         ([
                          
                          ] ++ (viewMainBody model))
                    True ->
                        div[class "container-md", Html.Attributes.style "padding" "100px"]
                        [
                           div[class "row justifu-content-center", Html.Attributes.style "margin-bottom" "40px"]
                           [
                               div[class "col"]
                               [
                                  span[class "price_table_main_field"][text "You have successfully verified your Account"]
                               ]
                           ]
 
                        , div[class "row"]
                          [
                               div[class "col", Html.Attributes.align "center"]
                               [
                                  svgOwlActive
                               ]
                           ]
                        ]


viewMainBody : Model -> List (Html Msg)
viewMainBody model = 
    [
      div[class "row", Html.Attributes.style "margin-top" "2rem"]
          [
            case getDocumentName model of
                Just name ->
                   div[class "col"]
                    [
                       img[src "/images/passport.svg",Html.Attributes.style "width" "2vw", Html.Attributes.style "margin-right" "1vw"][]
                    ,   span[Html.Attributes.style "color" "rgba(0,99,166,1)",Html.Attributes.style "font-size" "1.5rem" , Html.Attributes.style "font-weight" "bold"][text name]
                    ]
                Nothing ->
                    div[][]
          ]
      ,   div[class "row", Html.Attributes.style "margin-top" "1vh"]
          [
              case getDocumentName model of
                  Just name ->
                    div[class "col"]
                    [
                       case name of
                           "A selfie of you holding your document" ->
                             span[][text ("Please upload a selfie photo of you, holding your ID document. Be sure that all your face and all the ID document's data are readable and clearly visible" )]
                           _ ->
                             span[][text ("Please upload a clear photo of your document. Be sure that all the uploaded data are readable" )]
                    ]   
                  Nothing ->
                      div[][]
          ]

      ,  viewHeader model
      ,   div[class "row"]
          [ 
            (case getCurrentState model of
                Initial -> 
                  div[class "col"]
                  [
                  div
                   [ Html.Attributes.style "border" (if model.hover then "6px dashed purple" else "6px dashed #ccc")
                   , Html.Attributes.style "border-radius" "20px"
                   , Html.Attributes.style "width" "480px"
                   , Html.Attributes.style "height" "350px"
                   , Html.Attributes.style "margin" "50px auto"
                   , Html.Attributes.style "padding" "20px"
                   , Html.Attributes.style "display" "flex"
                   , Html.Attributes.style "flex-direction" "column"
                   , Html.Attributes.style "justify-content" "center"
                   , Html.Attributes.style "align-items" "center"
                   , hijackOn "dragenter" (Json.Decode.succeed DragEnter)
                   , hijackOn "dragover" (Json.Decode.succeed DragEnter)
                   , hijackOn "dragleave" (Json.Decode.succeed DragLeave)
                   , hijackOn "drop" dropDecoder
                   ]
                   [ {--button [ onClick Pick ] [ text "Upload Images" ]
                     , span [ style "color" "#ccc" ] [ text (Debug.toString model) ]--}
                      img[src "images/upload.svg", Html.Attributes.style "width" "20%"][] 
                    , span[Html.Attributes.style "margin-top" "20px"][text "Drag files to upload"]
                    , br[][]
                    , span[][text "JPEG or PNG files only"]
                    ]
                 , button
                    [
                     onClick FileS,  Html.Attributes.style "padding" "10px 20px", class "btn btn-primary", Html.Attributes.style "border-radius" "25px",Html.Attributes.style "font-size" "1.35rem", Html.Attributes.style "font-weight" "bold", Html.Attributes.style "background-color" "rgb(0, 99, 166)" , Html.Attributes.style "text-shadow" "1.5px 0 white", Html.Attributes.style "letter-spacing" "1px", Html.Attributes.style "width" "50%", Html.Attributes.style "margin-right" "25%", Html.Attributes.style "margin-left" "25%"
                    ]
                    [text "Browse Files"]
                  ]

                Uploading ->
                    div[class "col"]
                    [
                      img[src "images/loading.svg"][]
                    ]
                Uploaded ->
                    div[class "col"]
                    [ 
                      img[src "images/tick.svg"][]
                    ]
                _ ->
                  div[]
                  [
                    div
                   [ Html.Attributes.style "border" (if model.hover then "6px dashed purple" else "6px dashed #ccc")
                   , Html.Attributes.style "border-radius" "20px"
                   , Html.Attributes.style "width" "480px"
                   , Html.Attributes.style "height" "350px"
                   , Html.Attributes.style "margin" "50px auto"
                   , Html.Attributes.style "padding" "20px"
                   , Html.Attributes.style "display" "flex"
                   , Html.Attributes.style "flex-direction" "column"
                   , Html.Attributes.style "justify-content" "center"
                   , Html.Attributes.style "align-items" "center"
                   , hijackOn "dragenter" (Json.Decode.succeed DragEnter)
                   , hijackOn "dragover" (Json.Decode.succeed DragEnter)
                   , hijackOn "dragleave" (Json.Decode.succeed DragLeave)
                   , hijackOn "drop" dropDecoder
                   ]
                   [ {--button [ onClick Pick ] [ text "Upload Images" ]
                     , span [ style "color" "#ccc" ] [ text (Debug.toString model) ]--}
                      img[src "images/upload.svg", Html.Attributes.style "width" "20%"][] 
                    , span[Html.Attributes.style "margin-top" "20px"][text "Drag files to upload"]
                    , br[][]
                    , span[][text "JPG files only"]
                    ]
                 , button
                    [
                     onClick FileS,  Html.Attributes.style "padding" "10px 20px", class "btn btn-primary", Html.Attributes.style "border-radius" "25px",Html.Attributes.style "font-size" "1.35rem", Html.Attributes.style "font-weight" "bold", Html.Attributes.style "background-color" "rgb(0, 99, 166)" , Html.Attributes.style "text-shadow" "1.5px 0 white", Html.Attributes.style "letter-spacing" "1px", Html.Attributes.style "width" "50%", Html.Attributes.style "margin-right" "25%", Html.Attributes.style "margin-left" "25%"

                    ]
                    [text "Select file"]
                  ]
            )
         ]
   ]






getCurrentState : Model -> UploadingStatus
getCurrentState model =
    case model.step of
        Nothing ->
            Uploaded
        Just step ->
            case step of
                First ->
                    model.uploadingPhotoIdFront
                Second ->
                    model.uploadingPhotoIdBack
                Third ->
                    model.uploadingPhotoOfi
                Forth ->
                    model.uploadingPhotoSelfie


getDocumentName : Model -> Maybe String
getDocumentName model =
    case model.step of
        Nothing -> 
            Nothing
        Just step ->
           case step of
              First ->
                 Just "Front side of Identity card, Passport or Driver's License"
              Second ->
                 Just "Back side of the previous step document"
              Third ->
                 Just "Utillity Bill (maximum 3 months old)"
              Forth ->
                 Just "A selfie of you holding your document"

dropDecoder : Json.Decode.Decoder Msg
dropDecoder =
  Json.Decode.at ["dataTransfer","files"] (Json.Decode.oneOrMore GotFiles2 File.decoder)


hijackOn : String -> Json.Decode.Decoder msg -> Attribute msg
hijackOn event decoder =
  preventDefaultOn event (Json.Decode.map hijack decoder)


hijack : msg -> (msg, Bool)
hijack msg =
  (msg, True)


{--getColor : Step -> Model -> String
getColor step model =
    case step == model.step of
        True ->
            "0063a6"
        False ->
            "707070"--}


circle : String -> String -> Step -> Html Msg
circle step color stepO= 
  svg [onClick (ChangeStepTo stepO),Html.Attributes.style "cursor" "pointer",Html.Attributes.style "width" "35px",Html.Attributes.style "height" "35px" ,width "210mm", height "210mm", viewBox "0 0 210 210", version "1.1", id "svg8" ] [ defs [ id "defs2" ] [], metadata [ id "metadata5" ] [], g [ id "layer1", transform "translate(0,-87)" ] [ ellipse [ id "path224", cx "105.83334", cy "192.3006", rx "105.83333", ry "104.6994", style ("stroke-width:0.2618908;fill:#"++color++";fill-opacity:1") ] [], text_ [ style "font-style:normal;font-weight:normal;font-size:101.35233307px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:#ffffff;fill-opacity:1;stroke:#ffffff;stroke-width:0.71968651;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;", x "75.21122", y "230.41846", id "text4662", transform "scale(1.0221821,0.97829928)" ] [ tspan [ id "tspan4660", x "75.21122", y "230.41846", style "fill:#ffffff;fill-opacity:1;stroke:#ffffff;stroke-width:0.71968651;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;" ] [ text step ] ] ] ]


subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.none

svgOwlActive : Html Msg
svgOwlActive = 
    svg [ version "1.1", id "Layer_1", x "0px", y "0px", viewBox "0 0 800 800", Svg.Attributes.style "enable-background:new 0 0 800 800;" ] 
    [ Svg.style [] [ text "" ]
    , g [] [ Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", Svg.Attributes.d "M610.1,275.7c36.9-54,23.1-127.8-31-164.7c-16.8-11.5-36.3-18.5-56.6-20.2l63.5-42.6l-15-22.1L408.5,135.5 L246,26l-14.6,22.1l63.5,42.6c-65.2,5.7-113.5,63.1-107.8,128.3c1.8,20.3,8.7,39.8,20.2,56.6C92.2,387,89.2,570.6,200.5,685.7 s294.9,118.1,410,6.8s118.1-294.9,6.8-410c-2.2-2.3-4.5-4.5-6.8-6.8H610.1z M600.5,208.9c0,16.5-4.7,32.7-13.4,46.7 c-2.6,4.3-5.7,8.4-9,12.2c-3.4,3.9-7.1,7.4-11.2,10.6c-33.6,26.8-81.6,25.4-113.6-3.3l-3.8-3.4c-4.6-4.6-8.7-9.7-12.2-15.2 c-3.1-4.8-5.6-9.8-7.7-15.1c-2.1-5.4-3.7-10.9-4.7-16.5c-0.9-5-1.4-10.1-1.5-15.2l0,0c0-4.9,0.5-9.8,1.3-14.6 c7.6-48.2,52.9-81,101.1-73.4c43.2,6.9,74.9,44.3,74.5,88L600.5,208.9z M411.3,271.4c7.2,11.5,16.3,21.6,26.9,30.1l-1.8,3 l-8.2,14.2l-8.4,14.5l-11.1,19.2l-11.1-19.2l-8.2-14.5l-8.2-14.2l-1.8-3c10.5-8.5,19.5-18.6,26.6-30.1H411.3z M408.5,412.9l42.7-74 c64.1,18.9,108.3,77.6,108.7,144.4l0,0c0,83.5-67.6,151.2-151,151.2c-83.5,0-151.2-67.6-151.2-151c0-0.1,0-0.1,0-0.2l0,0 c0.1-67,44.2-125.9,108.4-144.9L408.5,412.9z M305,120.9c43.2,0.1,79.9,31.3,87.1,73.9c0.8,4.8,1.3,9.7,1.3,14.6l0,0 c-0.1,5.1-0.6,10.2-1.5,15.2c-1.1,5.7-2.7,11.2-4.7,16.5c-2,5.3-4.6,10.3-7.7,15.1c-3.5,5.5-7.6,10.6-12.2,15.2l-3.8,3.4 c-3.8,3.4-7.9,6.4-12.2,9.1c-4.3,2.7-8.8,5-13.5,6.9c-29.4,12.1-63,7.5-88-12.2c-4.1-3.1-7.8-6.7-11.2-10.6 c-3.3-3.8-6.4-7.9-9-12.2c-25.8-41.5-13.1-96,28.4-121.8c14-8.7,30.2-13.3,46.7-13.3L305,120.9z M408.5,744.1 c-143.7-0.2-260-116.8-259.8-260.5c0-0.1,0-0.2,0-0.2l0,0c0-69.9,28.2-136.9,78.2-185.7c21.6,19,49.3,29.4,78,29.4 c4.1,0,8.1-0.3,12.2-0.7c-55.8,32.6-90.1,92.3-90,157l0,0C229.7,583.5,313,662.6,413.2,660c96.5-2.5,174.2-80.1,176.7-176.7l0,0 c-0.2-64.6-34.8-124.2-90.8-156.5c4.3,0.5,8.6,0.7,12.9,0.7c28.7,0,56.4-10.5,78-29.4c50,48.7,78.2,115.4,78.4,185.2l0,0 c0.1,143.6-116.2,260.1-259.8,260.3L408.5,744.1z" ] []
           , Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", Svg.Attributes.d "M282.5,240c5.8,4.2,12.8,6.8,20,7.3h2.6c2.4-0.1,4.9-0.3,7.3-0.7c4.6-1,8.9-2.7,12.9-5.2 c2.5-1.6,4.9-3.5,7.1-5.6c4.9-5.1,8.4-11.5,10-18.5c0.5-2.7,0.8-5.4,0.9-8.2c0-2.5-0.2-5-0.7-7.4c-4.4-20.6-24.7-33.8-45.4-29.4 c-17.4,3.7-29.9,19-30.2,36.8C266.9,221.3,272.7,232.7,282.5,240z" ] []
           , Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", Svg.Attributes.d "M408.5,449.4v-30.2c-38.3,0.3-71.3,26.8-79.8,64.1c-1.3,5.8-1.9,11.8-1.9,17.8c0.1,45.5,37,82.3,82.5,82.3 c33,0,62.8-19.8,75.7-50.1c4.3-10.2,6.4-21.1,6.4-32.1v-14.6H409v30.2h50c0,1.8-1.2,3.5-1.9,5.2c-11.2,26.5-41.9,38.9-68.4,27.7 c-19.3-8.2-31.8-27.1-31.8-48c0-6.1,1.1-12.1,3.2-17.8C367.4,463.4,386.8,449.7,408.5,449.4z" ] []
           , Svg.path [Svg.Attributes.fill "rgba(58,213,160,1)", Svg.Attributes.class "st0", Svg.Attributes.d "M474.7,201.5c-0.5,2.4-0.7,4.9-0.7,7.4c0,2.7,0.3,5.5,0.9,8.2c3.4,14.7,15,26.2,29.8,29.3 c2.5,0.4,4.9,0.7,7.4,0.7h2.6c7.2-0.6,14.1-3.1,20-7.3c9.7-7.2,15.5-18.6,15.7-30.7c-0.3-21.1-17.7-37.9-38.8-37.6 c-17.8,0.3-33.1,12.8-36.8,30.2V201.5z" ] [] ] ]

