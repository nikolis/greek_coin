module Asset exposing (Image, defaultAvatar, error, loading, src, profile, done, warning, deposit, upArrow, downArrow, logo, logo2, facebookIcon, twitterIcon, googleplusIcon, walletIcon, homeScreen, bank, card, hands, piggie, guard, bitcoinN, logoSvgHor, customers, blockChain, earth)

{-| Assets, such as images, videos, and audio. (We only have images for now.)

We should never expose asset URLs directly; this module should be in charge of
all of them. One source of truth!

-}

import Html exposing (Attribute, Html)
import Html.Attributes as Attr


type Image
    = Image String

-- IMAGES

customers : Image
customers =
    image "customers.svg"

blockChain : Image
blockChain =
    image "blockchain.svg"

earth : Image
earth =
    image "earth.svg"

error : Image
error =
    image "error.jpg"

bank: Image
bank = 
    image "bank.svg"

bitcoinN : Image
bitcoinN = 
    image "botcoin_neurons.svg"

card : Image
card = 
    image "cards.svg"

hands : Image
hands = 
    image "hands.svg"

piggie : Image
piggie = 
    image "piggie.svg"

guard : Image
guard = 
    image "safety.svg"

logoSvgHor : Image
logoSvgHor = 
    image "logo-horizontal.svg"


upArrow : Image
upArrow = 
    image "arrow.svg"

downArrow : Image
downArrow = 
    image "down-arrow.svg"

facebookIcon : Image
facebookIcon = 
    image "facebook_logo.svg"

twitterIcon : Image
twitterIcon = 
    image "twitter_diko_m.svg"

walletIcon : Image
walletIcon = 
    image "wallet.svg"

googleplusIcon : Image
googleplusIcon = 
    image "google_plus_mine.svg"

logo : Image
logo = 
    image "Logos-02.svg"

logo2 : Image
logo2 = 
    image "logo.svg"

homeScreen : Image
homeScreen = image "background.svg"

warning : Image
warning = 
    image "undraw_notify_88a4.svg"

done : Image
done = 
    image "tick.svg"

deposit : Image
deposit = 
    image "undraw_investment_xv9d.svg"

profile : Image
profile = 
    image "undraw_profile_6l1l.svg"

loading : Image
loading =
    image "loading.svg"


defaultAvatar : Image
defaultAvatar =
    image "smiley-cyrus.jpg"


image : String -> Image
image filename =
    Image ("/images/" ++ filename)



-- USING IMAGES


src : Image -> Attribute msg
src (Image url) =
    Attr.src url
