module Api.Calls exposing (fetchFeed) 

import Task exposing (Task)
import Api.Data exposing (..)
import Http.Legacy
import Session exposing (Session)
import Api.Endpoint as Endpoint
import Api exposing (Cred)

fetchFeed : Session  -> Task Http.Legacy.Error (KrakenResponse)
fetchFeed session   =
    let
        maybeCred =
            Session.cred session

        request =
            Api.get Endpoint.asset_pairs Nothing  decoderKraken
    in
    Http.Legacy.toTask request

