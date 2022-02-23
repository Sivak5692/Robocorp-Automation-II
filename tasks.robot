*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Process the robots and save the output in a zip.
Library           RPA.Browser.Selenium    auto_close=${False}
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.Tables

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the intranet website
    Download and read the orders file as a table
    Click on Preview button and take screenshot
    Submit the form
    Handle error on clicking submit

*** Variables ***
#${element_Exists}=    Does Page Contain Element    class:alert-danger #test

*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Wait And Click Button    class:btn-dark

Download and read the orders file as a table
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders} =    Read table from CSV    orders.csv    header=True
    FOR    ${order}    IN    @{orders}
        Fill the form    ${order}
        Log    ${order}
    END

Fill the form
    [Arguments]    ${orders}
    Select From List By Value    head    ${orders}[Head]
    Select Radio Button    body    ${orders}[Body]
    Input Text    xpath=/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${orders}[Legs]
    Input Text    address    ${orders}[Address]
    Click on Preview button and take screenshot
    Submit the form
    Handle error on clicking submit

Click on Preview button and take screenshot
    Click Button    id:preview
    Wait Until Page Contains Element    id:robot-preview

Submit the form
    Scroll Element Into View    id:order
    Click Element    id:order

Handle error on clicking submit
    ${element_Exists}=    Does Page Contain Element    class:alert-danger
    IF    ${element_Exists} == True
        Wait Until Keyword Succeeds    2x    5s    Submit the form
    END
    Run Keyword And Continue On Failure    Submit the form
    Click Button    id:order-another
    Wait And Click Button    class:btn-dark
