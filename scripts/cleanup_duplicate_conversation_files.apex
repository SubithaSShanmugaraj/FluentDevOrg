/**
 * Cleanup Script: Remove Duplicate Fluent Conversation Intelligence Files
 * 
 * PROBLEM: The old version of FluentLeadCreationService created a new file
 * every time a conversation was logged, resulting in many duplicate files
 * (36 files for only 2 leads).
 * 
 * SOLUTION: This script removes all duplicate files and keeps only the most
 * recent version for each lead.
 * 
 * HOW TO RUN:
 * 1. Open Developer Console in Salesforce
 * 2. Go to Debug > Open Execute Anonymous Window
 * 3. Copy and paste this script
 * 4. Click "Execute"
 * 
 * WHAT IT DOES:
 * - Finds all "Fluent Conversation Intelligence" files
 * - Groups them by linked Lead
 * - Keeps the most recent file for each Lead
 * - Deletes all older duplicate files
 */

// Step 1: Find all Fluent Conversation Intelligence files
System.debug('===== STARTING CLEANUP OF DUPLICATE CONVERSATION FILES =====');

// First, get all ContentDocuments with the title we're looking for
List<ContentDocument> allDocs = [
    SELECT Id, Title, CreatedDate
    FROM ContentDocument
    WHERE Title LIKE 'Fluent Conversation Intelligence%'
    ORDER BY CreatedDate DESC
];

System.debug('Found ' + allDocs.size() + ' total conversation intelligence documents');

// Get the IDs to query links
Set<Id> docIds = new Set<Id>();
for (ContentDocument doc : allDocs) {
    docIds.add(doc.Id);
}

// Now get the links to see which leads they're attached to
List<ContentDocumentLink> allLinks = [
    SELECT Id, LinkedEntityId, ContentDocumentId
    FROM ContentDocumentLink
    WHERE ContentDocumentId IN :docIds
    AND LinkedEntityId != null
];

System.debug('Found ' + allLinks.size() + ' total file links');

// Create a map of document ID to document for easy lookup
Map<Id, ContentDocument> docMap = new Map<Id, ContentDocument>();
for (ContentDocument doc : allDocs) {
    docMap.put(doc.Id, doc);
}

// Step 2: Group files by Lead
Map<Id, List<ContentDocumentLink>> leadToFiles = new Map<Id, List<ContentDocumentLink>>();

for (ContentDocumentLink link : allLinks) {
    Id leadId = link.LinkedEntityId;
    
    if (!leadToFiles.containsKey(leadId)) {
        leadToFiles.put(leadId, new List<ContentDocumentLink>());
    }
    
    leadToFiles.get(leadId).add(link);
}

System.debug('Files are linked to ' + leadToFiles.size() + ' different leads');

// Step 3: Identify files to keep vs delete
Set<Id> docsToKeep = new Set<Id>();
Set<Id> docsToDelete = new Set<Id>();

for (Id leadId : leadToFiles.keySet()) {
    List<ContentDocumentLink> filesForLead = leadToFiles.get(leadId);
    
    System.debug('Lead ' + leadId + ' has ' + filesForLead.size() + ' files');
    
    if (filesForLead.size() > 1) {
        // Sort by creation date (most recent first)
        for (Integer i = 0; i < filesForLead.size() - 1; i++) {
            for (Integer j = i + 1; j < filesForLead.size(); j++) {
                ContentDocument doc1 = docMap.get(filesForLead[i].ContentDocumentId);
                ContentDocument doc2 = docMap.get(filesForLead[j].ContentDocumentId);
                
                if (doc1.CreatedDate < doc2.CreatedDate) {
                    ContentDocumentLink temp = filesForLead[i];
                    filesForLead[i] = filesForLead[j];
                    filesForLead[j] = temp;
                }
            }
        }
        
        // Keep the most recent file (first after sorting)
        ContentDocument keepDoc = docMap.get(filesForLead[0].ContentDocumentId);
        docsToKeep.add(filesForLead[0].ContentDocumentId);
        System.debug('  ✓ Keeping: ' + keepDoc.Title + 
                    ' (Created: ' + keepDoc.CreatedDate + ')');
        
        // Mark the rest for deletion
        for (Integer i = 1; i < filesForLead.size(); i++) {
            ContentDocument delDoc = docMap.get(filesForLead[i].ContentDocumentId);
            docsToDelete.add(filesForLead[i].ContentDocumentId);
            System.debug('  ✗ Deleting: ' + delDoc.Title + 
                        ' (Created: ' + delDoc.CreatedDate + ')');
        }
    } else {
        // Only one file, keep it
        docsToKeep.add(filesForLead[0].ContentDocumentId);
        System.debug('  ✓ Only 1 file, keeping it');
    }
}

System.debug('');
System.debug('===== CLEANUP SUMMARY =====');
System.debug('Total files found: ' + allLinks.size());
System.debug('Files to keep: ' + docsToKeep.size());
System.debug('Files to delete: ' + docsToDelete.size());

// Step 4: Delete duplicate files (if any)
if (docsToDelete.isEmpty()) {
    System.debug('');
    System.debug('✓ No duplicate files found. System is clean!');
} else {
    List<ContentDocument> documentsToDelete = [
        SELECT Id, Title 
        FROM ContentDocument 
        WHERE Id IN :docsToDelete
    ];
    
    System.debug('');
    System.debug('Deleting ' + documentsToDelete.size() + ' duplicate files...');
    
    try {
        delete documentsToDelete;
        System.debug('');
        System.debug('✓ SUCCESS! Deleted ' + documentsToDelete.size() + ' duplicate files');
        System.debug('✓ Each lead now has exactly 1 conversation intelligence file');
    } catch (Exception e) {
        System.debug('');
        System.debug('✗ ERROR: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
}

System.debug('');
System.debug('===== CLEANUP COMPLETE =====');

// Step 5: Verify cleanup
// Query documents again
List<ContentDocument> verifyDocs = [
    SELECT Id
    FROM ContentDocument
    WHERE Title LIKE 'Fluent Conversation Intelligence%'
];

Set<Id> verifyDocIds = new Set<Id>();
for (ContentDocument doc : verifyDocs) {
    verifyDocIds.add(doc.Id);
}

// Query links with document IDs
List<AggregateResult> remainingCounts = [
    SELECT LinkedEntityId, COUNT(Id) fileCount
    FROM ContentDocumentLink
    WHERE ContentDocumentId IN :verifyDocIds
    AND LinkedEntityId != null
    GROUP BY LinkedEntityId
];

System.debug('');
System.debug('===== VERIFICATION =====');
System.debug('Leads with conversation files: ' + remainingCounts.size());

Integer totalRemainingFiles = 0;
Integer leadsWithMultipleFiles = 0;

for (AggregateResult ar : remainingCounts) {
    Integer fileCount = (Integer)ar.get('fileCount');
    totalRemainingFiles += fileCount;
    
    if (fileCount > 1) {
        leadsWithMultipleFiles++;
        System.debug('⚠ Lead ' + ar.get('LinkedEntityId') + ' still has ' + fileCount + ' files');
    }
}

System.debug('Total remaining files: ' + totalRemainingFiles);
System.debug('');

if (leadsWithMultipleFiles == 0) {
    System.debug('✓✓✓ VERIFICATION PASSED! Each lead has exactly 1 file ✓✓✓');
} else {
    System.debug('⚠ WARNING: ' + leadsWithMultipleFiles + ' leads still have multiple files');
}

