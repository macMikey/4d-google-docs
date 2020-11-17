This document is a portion of the README file from Miyako's [4d-tips-google-service-account](https://github.com/miyako/4d-tips-google-service-account)

#### [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/OAuth2ServiceAccount)

> The Google OAuth 2.0 system supports server-to-server interactions such as those between a web application and a Google service. For this scenario you need a service account, which is an account that belongs to your application instead of to an individual end user. Your application calls Google APIs on behalf of the service account, so users aren't directly involved.

## Setup 



### 1. Google Cloud Platform Console

- Login to [**Google API Console**](https://console.developers.google.com/) with an **admin** account
- Navigate to [**IAM and admin**](https://console.developers.google.com/iam-admin)
- Select [**Service accounts**](https://console.developers.google.com/iam-admin/serviceaccounts)
- Select or create a project

<img width="500" src="https://user-images.githubusercontent.com/1725068/44443436-a012aa00-a612-11e8-996f-1d36f14d1d76.png" />

- Create a new service account
  - Service account name: ``(any)``
  - Service account ID: ``(any, will auto-fill)``
  - Click **Create**
  <img width="1372" alt="create-service-account-1" src="https://user-images.githubusercontent.com/10867016/83682531-067f7700-a5b2-11ea-8572-761e5d1079b6.png">
  
  
  
- Choose the role
  
  - **Project->Owner**
- Click **Continue**
<img width="1354" alt="create-service-account-2" src="https://user-images.githubusercontent.com/10867016/83682535-08e1d100-a5b2-11ea-9f1d-89a93064e068.png">
  
  
  
- Click **Create Key**
<img width="1917" alt="create-service-account-3" src="https://user-images.githubusercontent.com/10867016/83682539-0a12fe00-a5b2-11ea-8e76-43a2c2c2eeaf.png">



- Choose the key options
  - Key type: **JSON**
  - Click **Create**
<img width="1899" alt="create-service-account-4" src="https://user-images.githubusercontent.com/10867016/83682540-0aab9480-a5b2-11ea-9ec6-d743ef174bb2.png">
  

  
- Store the ``json`` file locally (you will never be able to generate it again)

- Navigate to [**APIs & Services**](https://console.developers.google.com/apis)

- Click **ENABLE APIS AND SERVICES**

<img width="500" src="https://user-images.githubusercontent.com/1725068/44443863-f7b21500-a614-11e8-8269-7e37069b6d2e.png" />

- Find the necessary [**SDK**](https://developers.google.com/identity/protocols/oauth2/scopes)

  - For example, to use the [**Directory API**](https://developers.google.com/admin-sdk/directory/) to manage users, find **Admin SDK**
  

<img width="500" src="https://user-images.githubusercontent.com/1725068/44443895-0f899900-a615-11e8-8ecc-823634f29d11.png" />

- Enable the **SDK**

<img width="500" src="https://user-images.githubusercontent.com/1725068/44443946-4cee2680-a615-11e8-849f-e48057c28ab3.png" />

* If you are not going to use one of the API's that require an **API Key** (such as Calendar), you can skip this step.  Otherwise, to create an **API KEY**

  * Go to [APIs & Services -> Credentials](https://console.cloud.google.com) 

  * Select "Create Credentials"

    <img width="1227" alt="create credentials button" src="https://user-images.githubusercontent.com/10867016/99341471-f275bc00-2857-11eb-8e99-aa4844840777.png">

  

  * Choose "API Key"<img width="1337" alt="api key menu item" src="https://user-images.githubusercontent.com/10867016/99341599-31a40d00-2858-11eb-89fb-340918dc2b63.png">

  

  * Copy the key (the upper button).

  * If you wish to increase security, click "Restrict Key" (optional)

    <img width="674" alt="api key created" src="https://user-images.githubusercontent.com/10867016/99341724-6dd76d80-2858-11eb-99d1-654d86cd712d.png">

  
  * The restrictions screen has a number of options

    <img width="1505" alt="restrict key screen" src="https://user-images.githubusercontent.com/10867016/99342081-14bc0980-2859-11eb-8319-0805c2fb2de1.png">

  

  

  For example, if you choose to restrict the key to only certain API's, you can choose them from a menu.

  <img width="760" alt="api restrictions" src="https://user-images.githubusercontent.com/10867016/99342180-46cd6b80-2859-11eb-8668-47a12ec915c0.png">

  

### 2. Google Domain Admin Console

- Delegate your app to act on behalf of any user in your domain
  - Login to [**Google Admin Console**](https://admin.google.com/) with an admin account

  <img width="500" src="https://user-images.githubusercontent.com/1725068/44444060-d43b9a00-a615-11e8-89a5-e60cc3fe6097.png" />

  - Select **Security**

  <img width="500" src="https://user-images.githubusercontent.com/1725068/44444126-42805c80-a616-11e8-968a-a6465da7cb66.png" />

  - Select **API Controls->Domain-Wide Delegation**

  <img width="750" src="https://user-images.githubusercontent.com/10867016/84146179-423e9480-aa29-11ea-92f9-874f03aeec02.png" />
  
  
  
- Click **Add New**
<img width="500" src="https://user-images.githubusercontent.com/10867016/84146700-1a036580-aa2a-11ea-83f2-c594f5df64e8.png"/>

  
  
  - Register the necessary [**scopes**](https://developers.google.com/identity/protocols/googlescopes)
    - Client Name: either the service account or the client ID
    - Enter the API scopes to grant.  **Note they are comma-delimited here** **You will need these later**.  For example, to use the [**Directory API**](https://developers.google.com/admin-sdk/directory/) to manage users, register the following:
    `https://apps-apis.google.com/a/feeds/domain/,https://www.googleapis.com/auth/admin.directory.user`
    
    

## Storing Your Key And Keeping It Safe
**Your key should remain private.  If you are using version control, such as *git*, you should keep the key out of your repository so that you do not accidentally share it.**
One way to do this is to put it in a private folder that will not be included in your repository.
1. In the **Resources** folder for your project, add a folder called **Private**
2. In your **.gitignore** file for your project, add the follwing line:
``Resources/Private``
3. Put your key into that folder
4. Check the updates to your repository to make sure that your key does not appear in the list of added/updated files.



# References
- [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2)

- [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/oauth2/service-account#httprest)

- [Control G Suite API access with domain-wide delegation](https://support.google.com/a/answer/162106)
