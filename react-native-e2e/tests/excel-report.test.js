const assert = require('assert');
const xlsx = require('xlsx');
const path = require('path');

describe('React Native Excel Report Generation E2E Test', () => {
    
    // Path where the React Native app generates the Excel report on Android
    // Ensure that your app saves the report here, e.g., using react-native-fs or expo-file-system
    const ANDROID_FILE_PATH = '/sdcard/Download/MonthlyReport.xlsx';
    
    // Path where the app generates the report on iOS Simulator sandbox
    // WebdriverIO handles iOS paths in XCUITest by referencing the app's standard Documents directory
    const IOS_FILE_PATH = '@com.dreamengine.app:documents/MonthlyReport.xlsx';

    it('should generate, save, and verify the Excel report structure and contents', async () => {
        
        // 1. Locate and click the 'Generate Report' button
        // In React Native, set testID="btn-generate-report" on the Touch/Press component
        // WebdriverIO maps 'testID' to the accessibility selector '~'
        const generateBtn = await $('~btn-generate-report');
        await generateBtn.waitForDisplayed({ timeout: 15000 });
        await generateBtn.click();
        
        console.log('Clicked "Generate Report" button. Waiting for export to complete...');

        // 2. Wait for confirmation toast or success message to ensure generation is done
        // In React Native, set testID="export-success-message" on the success label/toast
        const successToast = await $('~export-success-message');
        await successToast.waitForDisplayed({ 
            timeout: 20000, 
            reverse: false, 
            timeoutMsg: 'Excel generation did not display a success indicator' 
        });

        const successText = await successToast.getText();
        console.log(`Success indicator found: "${successText}"`);

        // 3. Determine the correct device file path depending on target platform
        const isAndroid = driver.isAndroid;
        const filePathOnDevice = isAndroid ? ANDROID_FILE_PATH : IOS_FILE_PATH;

        console.log(`Pulling generated Excel report from device: ${filePathOnDevice}`);

        // 4. Retrieve the Excel file from the device storage
        // Appium's pullFile returns the file contents as a Base64-encoded string
        let base64Data;
        try {
            base64Data = await driver.pullFile(filePathOnDevice);
        } catch (error) {
            throw new Error(`Failed to pull file from device. Ensure storage permissions are granted and that the file is saved at "${filePathOnDevice}". Detail: ${error.message}`);
        }

        // 5. Convert the Base64 string to a binary buffer
        const fileBuffer = Buffer.from(base64Data, 'base64');
        console.log(`Successfully pulled Excel report. File size: ${fileBuffer.length} bytes.`);

        // Save the file on the host runner disk so GitHub Actions can upload it as a build artifact
        const fs = require('fs');
        const artifactPath = path.join(__dirname, '../MonthlyReport.xlsx');
        fs.writeFileSync(artifactPath, fileBuffer);
        console.log(`Saved report artifact locally to: ${artifactPath}`);

        // 6. Parse the Excel workbook using sheetjs (xlsx)
        const workbook = xlsx.read(fileBuffer, { type: 'buffer' });

        // 7. Verify the workbook structure and sheets
        assert(workbook.SheetNames.length > 0, 'Workbook should contain at least one sheet.');
        
        const firstSheetName = workbook.SheetNames[0];
        console.log(`Verifying sheet name: "${firstSheetName}"`);
        assert.strictEqual(firstSheetName, 'Monthly Report', 'The first sheet name should match our expected name.');

        const sheet = workbook.Sheets[firstSheetName];

        // 8. Convert the sheet columns to JSON format
        const sheetData = xlsx.utils.sheet_to_json(sheet, { header: 1 });
        console.log('Parsed Sheet Row Matrix:', sheetData.slice(0, 3));

        // 9. Assert expected column headers are present in the first row (headers)
        const expectedHeaders = ['ID', 'User Name', 'Activity Date', 'Status', 'Generated Value'];
        const actualHeaders = sheetData[0];

        assert.deepStrictEqual(
            actualHeaders.map(h => String(h).trim()),
            expectedHeaders,
            `Excel columns should match the template schema. Expected: ${expectedHeaders}, Got: ${actualHeaders}`
        );

        // 10. Verify that actual data has been populated
        assert(sheetData.length > 1, 'Excel sheet should contain at least one data row.');
        
        const firstDataRow = sheetData[1];
        console.log('First user data row in Excel:', firstDataRow);
        
        // Assert some standard type or value patterns
        assert(firstDataRow[0] !== undefined, 'User ID should not be blank.');
        assert(typeof firstDataRow[1] === 'string', 'User Name should be a string.');
        assert(firstDataRow[3] === 'Active' || firstDataRow[3] === 'Inactive', 'Status should match valid enums.');
        
        console.log('Excel report verification complete. Test PASSED!');
    });
});
