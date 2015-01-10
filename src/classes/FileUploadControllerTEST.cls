/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class FileUploadControllerTEST {

	static testMethod void uploadTest() {
        //Split string 'file' in to two chunks, first chunk must be divisible by 3 for base64 encode with no padding
        Blob file1part1 = Blob.valueOf('This text re'); //length is 12 
        Blob file1part2 = Blob.valueOf('presents a dummy file');
        Blob file2part1 = Blob.valueOf('File2');
        
        String file1part1base64 = EncodingUtil.base64Encode(file1part1);
        String file1part2base64 = EncodingUtil.base64Encode(file1part2);
        String file2part1base64 = EncodingUtil.base64Encode(file2part1);
        
        //Create a test accound the 'file' can be attached to.
        Account acct = new Account(Name = 'test');
        insert acct;
        
        //Start the test
        Test.startTest();
        //Send first part of the file 1 to be uploaded
        String attachmentId = FileUploadController.attachBlob(acct.Id,'','fileName1','text',file1part1base64);
        
        //Send the second piece of the file 1 to be uploaded
        FileUploadController.attachBlob(acct.Id,attachmentId,'fileName1','text',file1part2base64);
        
        //Send the first piece of the file 2 to be uploaded
        attachmentId = FileUploadController.attachBlob(acct.Id,'','fileName2','text',file2part1base64);
        
        //Delete file 2
        FileUploadController.deleteAttachment(attachmentId);
        Test.stopTest();
        
        //Assert one file has been attached to the test account
        List<Attachment> attachments = [select Id, Body from Attachment where ParentId = :acct.Id];
        system.assert(attachments.size() == 1);
        
        //Assert the contents of the split file were recontructed correctly
        system.assert(attachments[0].Body.toString() == 'This text represents a dummy file');
    }
}