module Shapes.Sphere where

import Graphics.Rendering.OpenGL
import Graphics.UI.GLUT as GLUT
import Shapes.Polygon
import Text.ParserCombinators.Parsec
import Data.Char
import Graphics.UI.GLUT
import Graphics.Rendering.OpenGL
import Shapes.Polygon
import Appearence.Color
import Appearence.Translate
import Appearence.Rotate
import Appearence.Scale
import Data.List
import Appearence.Camera




makeVertexes :: [(GLfloat,GLfloat,GLfloat)] -> IO ()
makeVertexes = mapM_ (\(x,y,z)->vertex $ Vertex3 x y z)

renderAs :: PrimitiveMode -> [(GLfloat,GLfloat,GLfloat)] -> IO ()
renderAs figure ps = renderPrimitive figure $ makeVertexes ps


displayPoints points primitiveShape = do  
                        renderAs primitiveShape points
                        flush

circlePoints radius x y z number=do 
                                    [let alpha = twoPi * i /number
                                     in (radius*(sin (alpha)) ,radius * (cos (alpha)),0)|i <-[1,2..number]]
       where
         twoPi = 2*pi


circle radius x y z = circlePoints radius x y z 10000

renderCircle r x y z = displayPoints (circle r x y z) LineLoop
fillCircle r x y z= do
                     displayPoints (circle r x y z) Polygon
                  
{-hOpenGlCircle  myPoints radius = let x = getCord 1 (head myPoints)
				     y = getCord 2 (head myPoints)
				     z = getCord 3 (head myPoints)
				      in fillCircle radius x y z
-}
hOpenGlCircle myPoints radius = renderObject Solid (Sphere' radius 1000 1000)
getCord n (x,y,z)
		| n==1 = x	
		| n==2 = y
		| n==3 = z

sphereFound::[String] -> IO ()
sphereFound (x:xs) = let myPoints = (returnArgsCy 1 (x:xs))
                         rad    =  read (eatSpaces (head (xs)))
				in  parseRCy xs myPoints rad 
				     




returnArgsCy 0 _ = []
returnArgsCy a [] = []
returnArgsCy a (x:xs) = (returnArgCy x):(returnArgsCy (a-1) xs)


returnArgCy [] = (0.0,0.0,0.0)
returnArgCy (x:xs) = if x== '<'
                         then let (y1,z1) = (myFunc xs)
                               in let (y2,z2 )= (myFunc z1)
                                    in let (y3,z3 )= (myFunc z2)
                                         in ((read y1) , (read y2) , (-(read y3))) 
                         else returnArgCy xs


parseRCy []  myPoints r  = do 
                             currentColor $= Color4 1 0 0 0
                             --print ""
                             hOpenGlCircle  myPoints r 
                           --  rotate (read "90.0" :: GLfloat) $ Vector3 (read "0.3" :: GLfloat)  (read "0.0" :: GLfloat) (read "0.8" :: GLfloat)
parseRCy (xs:xss) myPoints r = do
                                    if (isInfixOf "color rgb" xs )
                                     then
                                       let interm= snd(splitAt (head(elemIndices '<' xs)) xs)
                                       in
                                        do
                                         setColorRGB (fst (splitAt (head(elemIndices '>' xs)) interm))
                                         parseRCy xss myPoints r
                                         
                                     else
                                       if (isInfixOf "translate" xs )
                                         then
                                           let interm= snd(splitAt (head(elemIndices '<' xs)) xs)
                                            in
                                             do
                                              translateImage (fst (splitAt (head(elemIndices '>' xs)) interm))
                                              parseRCy xss myPoints r
                                         else
                                           if (isInfixOf "rotate" xs )
                                             then
                                               let interm= snd(splitAt (head(elemIndices '<' xs)) xs)
                                                in
                                                 do
                                                  rotateImage (fst (splitAt (head(elemIndices '>' xs)) interm))
                                                  parseRCy xss myPoints r
                                             else
                                               if (isInfixOf "scale" xs )
                                               then
                                                 let interm= snd(splitAt (head(elemIndices '<' xs)) xs)
                                                  in
                                                   do
                                                    scaleImage1 (fst (splitAt (head(elemIndices '>' xs)) interm))
                                                    parseRCy xss myPoints r
                                               else
                                                 parseRCy xss myPoints r
                                  --  hOpenGlCylinder myPoints r h
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    











































