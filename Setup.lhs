#!/usr/bin/env runhaskell

> import Distribution.Simple
> import Distribution.PackageDescription
> import Distribution.Version
>
> import Distribution.Simple.LocalBuildInfo
> import Distribution.Simple.Program
> import Distribution.Verbosity
>
> import Data.List (findIndices)
>
> import System.Directory
> import System.Info
>
> main = defaultMainWithHooks simpleUserHooks {
>   hookedPrograms = [gslconfigProgram],
>
>   confHook = \pkg flags -> do
>     lbi <- confHook simpleUserHooks pkg flags
>     bi <- gslBuildInfo lbi
>
>     return lbi {
>       localPkgDescr = updatePackageDescription
>                         (Just bi, []) (localPkgDescr lbi)
>     }
> }
>
> gslBuildInfo = case os of
>     "mingw32" -> gslBuildInfoWindows
>     "linux" -> gslBuildInfoLinux
>     _ -> gslBuildInfoLinux
> gslconfigProgram = (simpleProgram "gsl-config")
>
> gslBuildInfoLinux :: LocalBuildInfo -> IO BuildInfo
> gslBuildInfoLinux lbi = do
>   (gslconfigProg, _) <- requireProgram verbosity
>                          gslconfigProgram (withPrograms lbi)
>   let gslconfig = rawSystemProgramStdout verbosity gslconfigProg
>
>   cflags <- words `fmap` gslconfig ["--cflags"]
>   libs <- words `fmap` gslconfig ["--libs"]
>
>   return emptyBuildInfo {
>       frameworks    =  [ libs !! (i+1)
>                        | i <- findIndices (== "-framework") libs
>                        , i + 1 < length libs ]
>     , extraLibs     = flag "-l" libs
>     , extraLibDirs  = flag "-L" libs
>     , includeDirs   = flag "-I" cflags
>   }
>   where
>     verbosity = normal -- honestly, this is a hack
>     flag f ws =
>       let l = length f in [ drop l w | w <- ws, take l w == f ]
>
> gslBuildInfoWindows :: LocalBuildInfo -> IO BuildInfo
> gslBuildInfoWindows lbi = do
>   libPath <- canonicalizePath "../../../gsl/installdir/lib"
>   includePath <- canonicalizePath "../../../gsl/installdir/include"
>   let cflags = words $ "-I\"" ++ includePath ++ "\""
>       libs = words $ "-L\"" ++ libPath ++ "\" -lgsl -lgslcblas -lm"
>
>   return emptyBuildInfo {
>       frameworks    =  [ libs !! (i+1)
>                        | i <- findIndices (== "-framework") libs
>                        , i + 1 < length libs ]
>     , extraLibs     = flag "-l" libs
>     , extraLibDirs  = flag "-L" libs
>     , includeDirs   = flag "-I" cflags
>   }
>   where
>     verbosity = normal -- honestly, this is a hack
>     flag f ws =
>       let l = length f in [ drop l w | w <- ws, take l w == f ]
>
>
