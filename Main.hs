-- Show it is possible to use Google Sheets
import Network.Curl
import Data.Aeson
import Data.ByteString (ByteString)
import qualified Data.ByteString  as BS
import Data.Aeson.Parser as Parser
import Data.Attoparsec.ByteString.Char8
import Data.Char

main = withCurlDo $ do
  key <- readFile "my.key"
  (code,str) <- curlGetString
  	         ("https://spreadsheets.google.com/feeds/worksheets/" ++
                (unwords $ words $ key) ++
                "/public/basic?alt=json")
		         []
  print code
  print str
  print (parseOnly Parser.value (myPack str))


myPack :: String -> ByteString
myPack = BS.pack . map (fromIntegral . ord)
