{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
-- Show it is possible to use Google Sheets
import Network.Curl
import Data.Aeson
import Data.ByteString (ByteString)
import qualified Data.ByteString  as BS
import qualified Data.ByteString.Lazy as BSL
import Data.Aeson.Parser as Parser
import Data.Attoparsec.ByteString.Char8
import Data.Char
import Data.Aeson.Encode.Pretty
import qualified Data.HashMap.Strict as HashMap
import qualified Data.Vector as V
import  Network.Curl.Download
import Data.Text(Text)

main = withCurlDo $ do
  key <- readFile "my.key"
  Right bs <- openURI
  	         ("https://spreadsheets.google.com/feeds/worksheets/" ++
                (unwords $ words $ key) ++
                "/public/basic?alt=json")
--  print code
--  print str
  let Right (obj :: Value) = parseOnly Parser.value bs
  let feed = label "feed"  obj
  let entry = label "entry" feed
  sequence_ [ do let c = label "content" e
                 print c
            | e <- toList entry
            ]
--  BSL.putStrLn (encodePretty entry)

toList :: Value -> [Value]
toList (Array o) = V.toList o
toList _ = error "toList failed, not an Array"

label :: Text -> Value -> Value
label lab (Object o) = case HashMap.lookup lab o of
                         Nothing -> error $ "lookup of " ++ show lab ++ " failed"
                         Just v -> v
label lab _ = error $ "lookup of " ++ show lab ++ " failed, not an object"

index :: Int -> Value -> Value
index ix (Array o) = o V.! ix
index ix _ = error $ "lookup of " ++ show ix ++ " failed, not an array"

len :: Value -> Int
len (Array o) = V.length o
len _ = error $ "len failed, not an array"
