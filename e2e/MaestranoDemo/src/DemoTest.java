import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.apache.commons.io.FileUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;
import org.testng.asserts.SoftAssert;

import com.relevantcodes.extentreports.ExtentReports;
import com.relevantcodes.extentreports.ExtentTest;
import com.relevantcodes.extentreports.LogStatus;

public class DemoTest {
	
	
    // Login Credentials
	static String EmailID = "jasmeet.somal@bugraptors.com";
	static String Password = "Mind@123";

	WebDriver driver;
	
	// Create object for extent report 
	ExtentReports extentReport =  new ExtentReports(System.getProperty("user.dir") + "\\Report\\test.html", true);
	ExtentTest logger;
	
	// Common function for taking screenshot
	
	public void takeScreenshot() {
		
		File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
		try {
			String screenShotPath=System.getProperty("user.dir") + "\\Report\\Screenshots\\test.png";
			FileUtils.copyFile(scrFile, new File(screenShotPath)); 
			String imgeHtmlPath=logger.addScreenCapture("Screenshots\\test.png").replace("<img", "<img width=\"150\" height=\"70\"");
			logger.log(LogStatus.FAIL, "Screenshort of BuGG :"+ imgeHtmlPath);
		} catch (IOException e) {
			throw new java.lang.RuntimeException("RUNTIME_ERROR : : Exception occur during take ScreenShot");
		}
		System.out.println("Screenshot has been generated");		    
	}
	
	//--------------------------------------------------------------------

	@BeforeClass

	public void openBrowser() throws InterruptedException {
		
		// Initialize the firefox driver
		driver = new FirefoxDriver();
		driver.manage().window().maximize();
		driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
		
	}

	@BeforeMethod
	
	// Before Method always run before the test(Testcase)

	public void openURL() throws InterruptedException {
		
		logger = extentReport.startTest("App login", "Logged into the app");
		driver.get("https://get.maestrano.com/");
		logger.log(LogStatus.INFO, "Enter App URL");
		Thread.sleep(3000);
		driver.findElement(By.xpath(".//*[@id='user_email']")).sendKeys(EmailID);
		logger.log(LogStatus.INFO, "Enter email address");
		driver.findElement(By.xpath(".//*[@id='user_password']")).sendKeys(Password);
		logger.log(LogStatus.INFO, "Enter password");
		driver.findElement(By.xpath(".//*[@id='new_user']/div[3]/button")).click();
		logger.log(LogStatus.INFO, "Click on sign in button");
		Thread.sleep(3000);
	}

	@Test(priority = 0)
	
	// First testcase in which new widget will be added and deleted.

	public void TC_Addwidget() throws InterruptedException {

		logger = extentReport.startTest("TC_Addwidget", "Add a new Widget");
		driver.findElement(By.xpath(".//*[@class='row section-lines']/div/p[4]")).click();
		logger.log(LogStatus.INFO, "Click on Sales tab");
		driver.findElement(By.xpath(".//*[@class='line-item ng-binding'][text()='Top opportunities']")).click();
		logger.log(LogStatus.INFO, "Click on Top opportunities sub tab");
		Thread.sleep(3000);
		String getTopOpportunities = driver
				.findElement(By.xpath(".//*[@class='editable-title ng-isolate-scope']/div[1]")).getText();
		Assert.assertEquals(getTopOpportunities, "TOP OPPORTUNITIES");
		logger.log(LogStatus.INFO, "Widget added successfully");
		driver.findElement(By.xpath(".//*[@class='btn top-button btn-close']/i")).click();
		logger.log(LogStatus.INFO, "Click on cross icon");
		driver.findElement(By.xpath(".//*[@class='btn btn-xs btn-danger ng-scope']")).click();
		logger.log(LogStatus.INFO, "Click on Delete button");
		List<WebElement> getElement = driver
				.findElements(By.xpath(".//*[@class='editable-title ng-isolate-scope']/div[1]"));
		int getSize = getElement.size();
		Assert.assertTrue(getSize == 0, "Widget not deleted");
		logger.log(LogStatus.INFO, "Widget deleted successfully");
	}
	
	
	
	@Test(priority = 1)
	
	// Second testcase in which new widget will be added and deleted but will fail due assertion issue.
	// Screenshot will generate and attached to the report

	public void TC_Fail() throws InterruptedException {

		logger = extentReport.startTest("TC_Fail", "This is fail testcase");
		driver.findElement(By.xpath(".//*[@class='row section-lines']/div/p[4]")).click();
		logger.log(LogStatus.INFO, "Click on Sales tab");
		driver.findElement(By.xpath(".//*[@class='line-item ng-binding'][text()='Top opportunities']")).click();
		logger.log(LogStatus.INFO, "Click on Top opportunities sub tab");
		Thread.sleep(3000);
		String getTopOpportunities = driver
				.findElement(By.xpath(".//*[@class='editable-title ng-isolate-scope']/div[1]")).getText();
		
		if(getTopOpportunities == "TOP OPPORTUNITIE"){
			System.out.println("String matched successfully");
		}
		else{
			
			takeScreenshot();
		}
		
		driver.findElement(By.xpath(".//*[@class='btn top-button btn-close']/i")).click();
		logger.log(LogStatus.INFO, "Click on cross icon");
		driver.findElement(By.xpath(".//*[@class='btn btn-xs btn-danger ng-scope']")).click();
		logger.log(LogStatus.INFO, "Click on Delete button");
		Thread.sleep(3000);
		List<WebElement> getElement = driver
				.findElements(By.xpath(".//*[@class='editable-title ng-isolate-scope']/div[1]"));
		int getSize = getElement.size();
		Assert.assertTrue(getSize == 0, "Widget not deleted");
		
		}
	

	@AfterMethod
	
	// After method will run after test(testcase)

	public void logout() {
		extentReport.flush();
		logger = extentReport.startTest("Logout", "Logout from the app");

		driver.findElement(By.xpath(".//*[@class='expand-menu fa fa-chevron-down']")).click();
		driver.findElement(By.xpath(".//*[@class='default-link']/span")).click();
		logger.log(LogStatus.INFO, "Click on logout button");
		extentReport.flush();
	}

	@AfterClass
	
	// Exit the browser

	public void exitBrowser() {

		driver.quit();
		
	}

}
