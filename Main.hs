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

main = withCurlDo $ do
  key <- readFile "my.key"
  (code,str) <- curlGetString
  	         ("https://spreadsheets.google.com/feeds/worksheets/" ++
                (unwords $ words $ key) ++
                "/public/basic?alt=json")
		         []
--  print code
--  print str
  let Right (Object obj :: Value) = parseOnly Parser.value (myPack str)
  let Just (Object feed)   = HashMap.lookup "feed"  obj
  let Just (Array entry)  = HashMap.lookup "entry" feed
  sequence_ [ do let Just (Object c) = HashMap.lookup "content" e
                 print c
            | Object e <- V.toList entry
            ]
--  BSL.putStrLn (encodePretty entry)

myPack :: String -> ByteString
myPack = BS.pack . map (fromIntegral . ord)
