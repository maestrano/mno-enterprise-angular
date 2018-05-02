set ProjectPath=%~dp0
cd %ProjectPath%
set classpath=%ProjectPath%\bin;%ProjectPath%\ExternalJars\Selenium_Java_2.53\*;%ProjectPath%\ExternalJars\extentreports-java-2.41.2\lib\*;%ProjectPath%\ExternalJars\extentreports-java-2.41.2\*;;%ProjectPath%\ExternalJars\PDF1.8\*;
java org.testng.TestNG Testng.xml
PAUSE