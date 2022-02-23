*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Process the robots and save the output in a zip.
Library           RPA.Browser.Selenium    auto_close=${False}
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.Tables
Library           RPA.RobotLogListener
Library           RPA.PDF
Library           RPA.FileSystem
Library           RPA.Archive
Library           RPA.Dialogs
#Library          RPA.Robocloud.Secrets

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    #Read url from a vault and open browser
    Close the modal
    Click on Preview button
    Submit the form
    Handle error on clicking submit
    Store the order receipt as a PDF file
    Order another robot
    Create a ZIP file of the receipts

*** Variables ***
${counter}=       0

*** Keywords ***
Open browser & Ask for users input
    #[Arguments]    ${secret}
    Add text input    name=URL    label=URL
    ${dialog}=    Show dialog    title=Enter URL of csv
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    #${secret}[url]
    ${result}=    Wait dialog    ${dialog}
    Download and read the orders file as a table    ${result.URL}

Read url from a vault and open browser
    #${secret}=    Get Secret    robotspare_url
    #Log    ${secret}[url]

Close the modal
    Wait And Click Button    class:btn-warning

Download and read the orders file as a table
    [Arguments]    ${result.URL}
    Download    ${result.URL}    overwrite=True
    ${orders} =    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Close the modal
        Fill the form    ${order}
        #${counter}=    Evaluate    ${counter} + 1
        #Exit For Loop If    ${counter} == 20
        Wait Until Keyword Succeeds    10x    5s    Click on Preview button
        Submit the form
        Handle error on clicking submit
        Store the order receipt as a PDF file
        Order another robot
    END
    Create a ZIP file of the receipts

Fill the form
    [Arguments]    ${orders}
    Select From List By Value    head    ${orders}[Head]
    Select Radio Button    body    ${orders}[Body]
    Input Text    xpath=/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${orders}[Legs]
    Input Text    address    ${orders}[Address]

Click on Preview button
    Click Button    id:preview
    Wait Until Page Contains Element    id:robot-preview

Submit the form
    click Element    id:order

Handle error on clicking submit
    ${alertElementExists}=    Does Page Contain Element    class:alert-danger
    ${submitBtnStillExists}=    Does Page Contain Element    id:order
    IF    ${alertElementExists} == True
        Wait Until Keyword Succeeds    15x    5s    Submit the form
        IF    ${submitBtnStillExists} == True
            Run Keyword And Ignore Error    Submit the form
        END
    END

Store the order receipt as a PDF file
    ${order_Id}=    Get Text    class:badge-success
    Log    ${order_Id}
    ${order_receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt_html}    ${OUTPUT_DIR}${/}pdfs${/}${order_Id}.pdf
    Take a screenshot of the robot image and save it in PDF    ${order_Id}

Take a screenshot of the robot image and save it in PDF
    [Arguments]    ${order_Id}
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}pdfs${/}${order_Id}.png
    Open Pdf    ${OUTPUT_DIR}${/}pdfs${/}${order_Id}.pdf
    Add Watermark Image To Pdf    ${OUTPUT_DIR}${/}pdfs${/}${order_Id}.png    ${OUTPUT_DIR}${/}pdfs${/}${order_Id}.pdf
    Close Pdf
    Remove Files    ${OUTPUT_DIR}${/}pdfs${/}${order_Id}.png

Order another robot
    Click Button    id:order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}pdfs    zipped_pdfs.zip
