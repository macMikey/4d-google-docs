# Class cGoogleCalendar



## Description

Class for accessing, creating, and maniuplating google calendars and events.

Extends *cGoogleComms*, **but** there should be at least one *cGoogleComms* object created separately that will be the "master".  Authorization header data should be copied from that object to the others.  Authorization headers should be checked periodically to see if they have expired or have been revoked, and then the new data shared after the authorization is renewed.



## Contents

[Additional Prerequisites](#Additional Prerequisites)

[Constructor Parameters](#Constructor Parameters)

[Calendar Properties](#Calendar Properties)

* [this.metadata object](#this.metadata object)

[Calendar API](#Calendar API)

* [createCalendar](#createCalendar) - create a calendar
* [getCalendarList](#getCalendarList) - get a list of calendars
* [setID](#setID) - change a calendar's ID

[Event Properties](#Event Properties)

* [Event Properties Structure And Types](#Event Properties Structure And Types)
* [Event Properties Descriptions](#Event Properties Descriptions)

[Events API](#Events API)

* [eventDelete](#eventDelete) - delete an event on a calendar
* [eventsGet](#eventsGet) - get the events from a particular calendar
* [eventInsert](#eventInsert)

[Internal Structure](# Internal Structure)

[Internal API](# Internal API)

[References](#References)



## Additional Prerequisites

In addition to the other steps described in the **cGoogleAuth** documentation, you need to create an API Key to use the Google Calendar API.  You can create an API key on the [Credentials page in the Google Cloud Platform Console](https://console.cloud.google.com/apis/credentials).  The API Key must be provided to the constructor when you create the calendar object.



## Constructor Parameters

|Name|Required|Datatype|Description|
|--|--|--|--|
|cGoogleAuth|**Required**|object|Object obtained from a *cGoogleComms* class via **getAuthAccess** |
|api_key|**Required**|Text|The API key created from the [Google Cloud Platform Console](https://console.cloud.google.com/apis/credentials)|
|URL|Optional|Text|The URL of the calendar you want to work with|




#### Constructor Example

```4d
var s : Object
If (OB Is empty (s))
  s:=cs.cGoogleCalendar.new(oGoogleComms;$url)
End if
```



## Calendar Properties

Property|Datatype|Description
--|--|--
status|Integer|http status
error|object|http error object (if status <>200)
metadata |Object|[The metadata for the calendar](this.metadata object) 
events|Collection|[Collection of Events](#Event Properties)



### this.metadata object

Contains the [Calendars Resource](https://developers.google.com/calendar/v3/reference/calendars#resource) metadata for the calendar


| Property name                                           | Value           | Description                                                  | Notes    |
| :------------------------------------------------------ | :-------------- | :----------------------------------------------------------- | :------- |
| `conferenceProperties`                                  | `nested object` | Conferencing properties for this calendar, for example what types of conferences are allowed. |          |
| `conferenceProperties.allowedConferenceSolutionTypes[]` | `list`          | The types of conference solutions that are supported for this calendar. The possible values are: `"eventHangout"``"eventNamedHangout"``"hangoutsMeet"`Optional. |          |
| `description`                                           | `string`        | Description of the calendar. Optional.                       | writable |
| `etag`                                                  | `etag`          | ETag of the resource.                                        |          |
| `id`                                                    | `string`        | Identifier of the calendar. To retrieve IDs call the [calendarList.list()](https://developers.google.com/calendar/v3/reference/calendarList/list)method. |          |
| `kind`                                                  | `string`        | Type of the resource ("`calendar#calendar`").                |          |
| `location`                                              | `string`        | Geographic location of the calendar as free-form text. Optional. | writable |
| `summary`                                               | `string`        | Title of the calendar.                                       | writable |
| `timeZone`                                              | `string`        | The time zone of the calendar. (Formatted as an IANA Time Zone Database name, e.g. "Europe/Zurich".) Optional. | writable |



## Calendar API

### createCalendar

**Syntax:** `createCalendar( calendarName: text) -> boolean`

**Summary:** Implements [Calenders:insert](https://developers.google.com/calendar/v3/reference/calendars/insert).

**Notes:** None

**Returns:**


* If the result is unsuccessful then **false** is returned, and **this.error** will have the error object.
* If the result is successful, **true** is returned and the [calendar's metadata](https://developers.google.com/calendar/v3/reference/calendars#resource) is loaded into the property **this.metadata**, making the new calendar the current calendar.



**Example:**

```4d
if not($calendar.createCalendar("test")) // fail
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
   ABORT
End If
```



### getCalendarList

**Syntax:** `getCalendarList () -> object`

**Summary:** Implements [CalendarList: list](https://developers.google.com/calendar/v3/reference/calendarList/list)

**Notes:**

* ***Does not implement any of the optional parameters***.

* Currently will only retrieve the first 100 calendars.
* Returns only non-deleted non-hidden calendars that the account in the *cGoogleAuth.Username* object can see.  For more information, see the **cGoogleAuth** class documentation.
* Does not pull the *syncToken* which is a timestamp of sorts that can be used to query Google for updates since the calendar info was retrieved.

**Returns:**

If successful, this method returns a response body object with the following structure:

```
{
  "kind": "calendar#calendarList",
  "etag": etag,
  "nextPageToken": string,
  "nextSyncToken": string,
  "items": [
    calendarList Resource
  ]
}
```

| Property name   | Value    | Description                                                  |
| :-------------- | :------- | :----------------------------------------------------------- |
| `kind`          | `string` | Type of the collection ("`calendar#calendarList`").          |
| `etag`          | `etag`   | ETag of the collection.                                      |
| `nextPageToken` | `string` | Token used to access the next page of this result. Omitted if no further results are available, in which case `nextSyncToken` is provided. |
| `items[]`       | `list`   | [Calendars that are present on the user's calendar list.](https://developers.google.com/calendar/v3/reference/calendarList#resource) (see below) |
| `nextSyncToken` | `string` | Token used at a later point in time to retrieve only the entries that have changed since this result was returned. Omitted if further results are available, in which case `nextPageToken` is provided. |

**Items List Format:**

```json
{
  "kind": "calendar#calendarListEntry",
  "etag": etag,
  "id": string,
  "summary": string,
  "description": string,
  "location": string,
  "timeZone": string,
  "summaryOverride": string,
  "colorId": string,
  "backgroundColor": string,
  "foregroundColor": string,
  "hidden": boolean,
  "selected": boolean,
  "accessRole": string,
  "defaultReminders": [
    {
      "method": string,
      "minutes": integer
    }
  ],
  "notificationSettings": {
    "notifications": [
      {
        "type": string,
        "method": string
      }
    ]
  },
  "primary": boolean,
  "deleted": boolean,
  "conferenceProperties": {
    "allowedConferenceSolutionTypes": [
      string
    ]
  }
}
```

| Property name                                           | Value           | Description                                                  | Notes    |
| :------------------------------------------------------ | :-------------- | :----------------------------------------------------------- | :------- |
| `accessRole`                                            | `string`        | The effective access role that the authenticated user has on the calendar. Read-only. Possible values are: "`freeBusyReader`" - Provides read access to free/busy information."`reader`" - Provides read access to the calendar. Private events will appear to users with reader access, but event details will be hidden."`writer`" - Provides read and write access to the calendar. Private events will appear to users with writer access, and event details will be visible."`owner`" - Provides ownership of the calendar. This role has all of the permissions of the writer role with the additional ability to see and manipulate ACLs. |          |
| `backgroundColor`                                       | `string`        | The main color of the calendar in the hexadecimal format "`#0088aa`". This property supersedes the index-based `colorId`property. To set or change this property, you need to specify `colorRgbFormat=true` in the parameters of the [insert](https://developers.google.com/calendar/v3/reference/calendarList/insert), [update](https://developers.google.com/calendar/v3/reference/calendarList/update)and [patch](https://developers.google.com/calendar/v3/reference/calendarList/patch) methods. Optional. | writable |
| `colorId`                                               | `string`        | The color of the calendar. This is an ID referring to an entry in the `calendar` section of the colors definition (see the [colors endpoint](https://developers.google.com/calendar/v3/reference/colors)). This property is superseded by the `backgroundColor`and `foregroundColor` properties and can be ignored when using these properties. Optional. | writable |
| `conferenceProperties`                                  | `nested object` | Conferencing properties for this calendar, for example what types of conferences are allowed. |          |
| `conferenceProperties.allowedConferenceSolutionTypes[]` | `list`          | The types of conference solutions that are supported for this calendar. The possible values are: `"eventHangout"``"eventNamedHangout"``"hangoutsMeet"`Optional. |          |
| `defaultReminders[]`                                    | `list`          | The default reminders that the authenticated user has for this calendar. | writable |
| `defaultReminders[].method`                             | `string`        | The method used by this reminder. Possible values are: "`email`" - Reminders are sent via email."`popup`" - Reminders are sent via a UI popup.Required when adding a reminder. | writable |
| `defaultReminders[].minutes`                            | `integer`       | Number of minutes before the start of the event when the reminder should trigger. Valid values are between 0 and 40320 (4 weeks in minutes). Required when adding a reminder. | writable |
| `deleted`                                               | `boolean`       | Whether this calendar list entry has been deleted from the calendar list. Read-only. Optional. The default is False. |          |
| `description`                                           | `string`        | Description of the calendar. Optional. Read-only.            |          |
| `etag`                                                  | `etag`          | ETag of the resource.                                        |          |
| `foregroundColor`                                       | `string`        | The foreground color of the calendar in the hexadecimal format "`#ffffff`". This property supersedes the index-based `colorId`property. To set or change this property, you need to specify `colorRgbFormat=true` in the parameters of the [insert](https://developers.google.com/calendar/v3/reference/calendarList/insert), [update](https://developers.google.com/calendar/v3/reference/calendarList/update)and [patch](https://developers.google.com/calendar/v3/reference/calendarList/patch) methods. Optional. | writable |
| `hidden`                                                | `boolean`       | Whether the calendar has been hidden from the list. Optional. The attribute is only returned when the calendar is hidden, in which case the value is `true`. | writable |
| `id`                                                    | `string`        | Identifier of the calendar.                                  |          |
| `kind`                                                  | `string`        | Type of the resource ("calendar#calendarListEntry").         |          |
| `location`                                              | `string`        | Geographic location of the calendar as free-form text. Optional. Read-only. |          |
| `notificationSettings`                                  | `object`        | The notifications that the authenticated user is receiving for this calendar. | writable |
| `notificationSettings.notifications[]`                  | `list`          | The list of notifications set for this calendar.             |          |
| `notificationSettings.notifications[].method`           | `string`        | The method used to deliver the notification. The possible value is: "`email`" - Notifications are sent via email.Required when adding a notification. | writable |
| `notificationSettings.notifications[].type`             | `string`        | The type of notification. Possible values are: "`eventCreation`" - Notification sent when a new event is put on the calendar."`eventChange`" - Notification sent when an event is changed."`eventCancellation`" - Notification sent when an event is cancelled."`eventResponse`" - Notification sent when an attendee responds to the event invitation."`agenda`" - An agenda with the events of the day (sent out in the morning).Required when adding a notification. | writable |
| `primary`                                               | `boolean`       | Whether the calendar is the primary calendar of the authenticated user. Read-only. Optional. The default is False. |          |
| `selected`                                              | `boolean`       | Whether the calendar content shows up in the calendar UI. Optional. The default is False. | writable |
| `summary`                                               | `string`        | Title of the calendar. Read-only.                            |          |
| `summaryOverride`                                       | `string`        | The summary that the authenticated user has set for this calendar. Optional. | writable |
| `timeZone`                                              | `string`        | The time zone of the calendar. Optional. Read-only.          |          |



**Example:**

```4d
$calendarList:=$calendar.getCalendarList()
$id:=$calendar.items[0].id
```



### setID

**Syntax:** `setID ( calendarID : text ) -> $idIsAValidCalendar:boolean`

**Description:**

* Sets **this.metadata.ID** of the *cGoogleCalendar* object to the ID passed in **calendarID**
* Checks to see if ID is a valid calendar, and returns a boolean indicating that it is or is not.
* If *ID* is a valid calendar, loads the calender properties into the **this.metadata** property per [Calendars: get](https://developers.google.com/calendar/v3/reference/calendars/get)

**Notes:**

* Does not revert **this.metadata.ID** if *ID* is not valid.  Maybe it should.

**Returns:** **True** if *ID* is valid and **False** if it is not valid

**Exampe:**

```4d
$valid:=$cal.setID($calendarID)
If (not($valid))
   Alert ("That is not a valid calendar id.")
End if
```



## Event Properties

Events have the following properties per [Google's docs](https://developers.google.com/calendar/v3/reference/events#resource-representations).  The following tables are copied verbatim from the docs.



### Event Properties Structure And Types

```json
{
  "kind": "calendar#event",
  "etag": etag,
  "id": string,
  "status": string,
  "htmlLink": string,
  "created": datetime,
  "updated": datetime,
  "summary": string,
  "description": string,
  "location": string,
  "colorId": string,
  "creator": {
    "id": string,
    "email": string,
    "displayName": string,
    "self": boolean
  },
  "organizer": {
    "id": string,
    "email": string,
    "displayName": string,
    "self": boolean
  },
  "start": {
    "date": date,
    "dateTime": datetime,
    "timeZone": string
  },
  "end": {
    "date": date,
    "dateTime": datetime,
    "timeZone": string
  },
  "endTimeUnspecified": boolean,
  "recurrence": [
    string
  ],
  "recurringEventId": string,
  "originalStartTime": {
    "date": date,
    "dateTime": datetime,
    "timeZone": string
  },
  "transparency": string,
  "visibility": string,
  "iCalUID": string,
  "sequence": integer,
  "attendees": [
    {
      "id": string,
      "email": string,
      "displayName": string,
      "organizer": boolean,
      "self": boolean,
      "resource": boolean,
      "optional": boolean,
      "responseStatus": string,
      "comment": string,
      "additionalGuests": integer
    }
  ],
  "attendeesOmitted": boolean,
  "extendedProperties": {
    "private": {
      (key): string
    },
    "shared": {
      (key): string
    }
  },
  "hangoutLink": string,
  "conferenceData": {
    "createRequest": {
      "requestId": string,
      "conferenceSolutionKey": {
        "type": string
      },
      "status": {
        "statusCode": string
      }
    },
    "entryPoints": [
      {
        "entryPointType": string,
        "uri": string,
        "label": string,
        "pin": string,
        "accessCode": string,
        "meetingCode": string,
        "passcode": string,
        "password": string
      }
    ],
    "conferenceSolution": {
      "key": {
        "type": string
      },
      "name": string,
      "iconUri": string
    },
    "conferenceId": string,
    "signature": string,
    "notes": string,
  },
  "gadget": {
    "type": string,
    "title": string,
    "link": string,
    "iconLink": string,
    "width": integer,
    "height": integer,
    "display": string,
    "preferences": {
      (key): string
    }
  },
  "anyoneCanAddSelf": boolean,
  "guestsCanInviteOthers": boolean,
  "guestsCanModify": boolean,
  "guestsCanSeeOtherGuests": boolean,
  "privateCopy": boolean,
  "locked": boolean,
  "reminders": {
    "useDefault": boolean,
    "overrides": [
      {
        "method": string,
        "minutes": integer
      }
    ]
  },
  "source": {
    "url": string,
    "title": string
  },
  "attachments": [
    {
      "fileUrl": string,
      "title": string,
      "mimeType": string,
      "iconLink": string,
      "fileId": string
    }
  ],
  "eventType": string
}
```



### Event Properties Descriptions

| Property name                                             | Value           | Description                                                  | Notes    |
| :-------------------------------------------------------- | :-------------- | :----------------------------------------------------------- | :------- |
| `anyoneCanAddSelf`                                        | `boolean`       | Whether anyone can invite themselves to the event (currently works for Google+ events only). Optional. The default is False. | writable |
| `attachments[]`                                           | `list`          | File attachments for the event. Currently only Google Drive attachments are supported. In order to modify attachments the `supportsAttachments` request parameter should be set to `true`. There can be at most 25 attachments per event, |          |
| `attachments[].fileId`                                    | `string`        | ID of the attached file. Read-only. For Google Drive files, this is the ID of the corresponding [`Files`](https://developers.google.com/drive/v3/reference/files) resource entry in the Drive API. |          |
| `attachments[].fileUrl`                                   | `string`        | URL link to the attachment. For adding Google Drive file attachments use the same format as in `alternateLink` property of the `Files` resource in the Drive API. Required when adding an attachment. | writable |
| `attachments[].iconLink`                                  | `string`        | URL link to the attachment's icon. Read-only.                |          |
| `attachments[].mimeType`                                  | `string`        | Internet media type (MIME type) of the attachment.           |          |
| `attachments[].title`                                     | `string`        | Attachment title.                                            |          |
| `attendeesOmitted`                                        | `boolean`       | Whether attendees may have been omitted from the event's representation. When retrieving an event, this may be due to a restriction specified by the `maxAttendee` query parameter. When updating an event, this can be used to only update the participant's response. Optional. The default is False. | writable |
| `attendees[]`                                             | `list`          | The attendees of the event. See the [Events with attendees](https://developers.google.com/calendar/concepts/sharing) guide for more information on scheduling events with other calendar users. Service accounts need to use [domain-wide delegation of authority](https://developers.google.com/calendar/auth#perform-g-suite-domain-wide-delegation-of-authority) to populate the attendee list. | writable |
| `attendees[].additionalGuests`                            | `integer`       | Number of additional guests. Optional. The default is 0.     | writable |
| `attendees[].comment`                                     | `string`        | The attendee's response comment. Optional.                   | writable |
| `attendees[].displayName`                                 | `string`        | The attendee's name, if available. Optional.                 | writable |
| `attendees[].email`                                       | `string`        | The attendee's email address, if available. This field must be present when adding an attendee. It must be a valid email address as per [RFC5322](https://tools.ietf.org/html/rfc5322#section-3.4). Required when adding an attendee. | writable |
| `attendees[].id`                                          | `string`        | The attendee's Profile ID, if available. It corresponds to the `id` field in the [People collection of the Google+ API](https://developers.google.com/+/web/api/rest/latest/people) |          |
| `attendees[].optional`                                    | `boolean`       | Whether this is an optional attendee. Optional. The default is False. | writable |
| `attendees[].organizer`                                   | `boolean`       | Whether the attendee is the organizer of the event. Read-only. The default is False. |          |
| `attendees[].resource`                                    | `boolean`       | Whether the attendee is a resource. Can only be set when the attendee is added to the event for the first time. Subsequent modifications are ignored. Optional. The default is False. | writable |
| `attendees[].responseStatus`                              | `string`        | The attendee's response status. Possible values are: "`needsAction`" - The attendee has not responded to the invitation."`declined`" - The attendee has declined the invitation."`tentative`" - The attendee has tentatively accepted the invitation."`accepted`" - The attendee has accepted the invitation. | writable |
| `attendees[].self`                                        | `boolean`       | Whether this entry represents the calendar on which this copy of the event appears. Read-only. The default is False. |          |
| `colorId`                                                 | `string`        | The color of the event. This is an ID referring to an entry in the `event` section of the colors definition (see the [colors endpoint](https://developers.google.com/calendar/v3/reference/colors)). Optional. | writable |
| `conferenceData`                                          | `nested object` | The conference-related information, such as details of a Google Meet conference. To create new conference details use the `createRequest` field. To persist your changes, remember to set the `conferenceDataVersion`request parameter to `1` for all event modification requests. | writable |
| `conferenceData.conferenceId`                             | `string`        | The ID of the conference. Can be used by developers to keep track of conferences, should not be displayed to users. Values for solution types: `"eventHangout"`: unset. `"eventNamedHangout"`: the name of the Hangout. `"hangoutsMeet"`: the 10-letter meeting code, for example `"aaa-bbbb-ccc"`. `"addOn"`: defined by 3P conference provider. Optional. |          |
| `conferenceData.conferenceSolution`                       | `nested object` | The conference solution, such as Hangouts or Google Meet. Unset for a conference with a failed create request. Either `conferenceSolution` and at least one `entryPoint`, or `createRequest` is required. |          |
| `conferenceData.conferenceSolution.iconUri`               | `string`        | The user-visible icon for this solution.                     |          |
| `conferenceData.conferenceSolution.key`                   | `nested object` | The key which can uniquely identify the conference solution for this event. |          |
| `conferenceData.conferenceSolution.key.type`              | `string`        | The conference solution type. If a client encounters an unfamiliar or empty type, it should still be able to display the entry points. However, it should disallow modifications. The possible values are: `"eventHangout"` for Hangouts for consumers (http://hangouts.google.com) `"eventNamedHangout"` for classic Hangouts for Google Workspace users (http://hangouts.google.com) `"hangoutsMeet"` for Google Meet (http://meet.google.com) `"addOn"` for 3P conference providers |          |
| `conferenceData.conferenceSolution.name`                  | `string`        | The user-visible name of this solution. Not localized.       |          |
| `conferenceData.createRequest`                            | `nested object` | A request to generate a new conference and attach it to the event. The data is generated asynchronously. To see whether the data is present check the `status` field. Either `conferenceSolution` and at least one `entryPoint`, or `createRequest` is required. |          |
| `conferenceData.createRequest.conferenceSolutionKey`      | `nested object` | The conference solution, such as Hangouts or Google Meet.    |          |
| `conferenceData.createRequest.conferenceSolutionKey.type` | `string`        | The conference solution type. If a client encounters an unfamiliar or empty type, it should still be able to display the entry points. However, it should disallow modifications. The possible values are: `"eventHangout"` for Hangouts for consumers (http://hangouts.google.com) `"eventNamedHangout"` for classic Hangouts for Google Workspace users (http://hangouts.google.com) `"hangoutsMeet"` for Google Meet (http://meet.google.com) `"addOn"` for 3P conference providers |          |
| `conferenceData.createRequest.requestId`                  | `string`        | The client-generated unique ID for this request. Clients should regenerate this ID for every new request. If an ID provided is the same as for the previous request, the request is ignored. |          |
| `conferenceData.createRequest.status`                     | `nested object` | The status of the conference create request.                 |          |
| `conferenceData.createRequest.status.statusCode`          | `string`        | The current status of the conference create request. Read-only. The possible values are: `"pending"`: the conference create request is still being processed. `"success"`: the conference create request succeeded, the entry points are populated. `"failure"`: the conference create request failed, there are no entry points. |          |
| `conferenceData.entryPoints[]`                            | `list`          | Information about individual conference entry points, such as URLs or phone numbers. All of them must belong to the same conference. Either `conferenceSolution` and at least one `entryPoint`, or `createRequest` is required. |          |
| `conferenceData.entryPoints[].accessCode`                 | `string`        | The access code to access the conference. The maximum length is 128 characters. When creating new conference data, populate only the subset of {`meetingCode`, `accessCode`, `passcode`, `password`, `pin`} fields that match the terminology that the conference provider uses. Only the populated fields should be displayed. Optional. |          |
| `conferenceData.entryPoints[].entryPointType`             | `string`        | The type of the conference entry point. Possible values are: `"video"` - joining a conference over HTTP. A conference can have zero or one `video` entry point. `"phone"` - joining a conference by dialing a phone number. A conference can have zero or more `phone` entry points. `"sip"` - joining a conference over SIP. A conference can have zero or one `sip` entry point. `"more"` - further conference joining instructions, for example additional phone numbers. A conference can have zero or one `more` entry point. A conference with only a `more` entry point is not a valid conference. |          |
| `conferenceData.entryPoints[].label`                      | `string`        | The label for the URI. Visible to end users. Not localized. The maximum length is 512 characters. Examples: for `video`: meet.google.com/aaa-bbbb-ccc for `phone`: +1 123 268 2601 for `sip`: 12345678@altostrat.com for `more`: should not be filled Optional. |          |
| `conferenceData.entryPoints[].meetingCode`                | `string`        | The meeting code to access the conference. The maximum length is 128 characters. When creating new conference data, populate only the subset of {`meetingCode`, `accessCode`, `passcode`, `password`, `pin`} fields that match the terminology that the conference provider uses. Only the populated fields should be displayed. Optional. |          |
| `conferenceData.entryPoints[].passcode`                   | `string`        | The passcode to access the conference. The maximum length is 128 characters. When creating new conference data, populate only the subset of {`meetingCode`, `accessCode`, `passcode`, `password`, `pin`} fields that match the terminology that the conference provider uses. Only the populated fields should be displayed. |          |
| `conferenceData.entryPoints[].password`                   | `string`        | The password to access the conference. The maximum length is 128 characters. When creating new conference data, populate only the subset of {`meetingCode`, `accessCode`, `passcode`, `password`, `pin`} fields that match the terminology that the conference provider uses. Only the populated fields should be displayed. Optional. |          |
| `conferenceData.entryPoints[].pin`                        | `string`        | The PIN to access the conference. The maximum length is 128 characters. When creating new conference data, populate only the subset of {`meetingCode`, `accessCode`, `passcode`, `password`, `pin`} fields that match the terminology that the conference provider uses. Only the populated fields should be displayed. Optional. |          |
| `conferenceData.entryPoints[].uri`                        | `string`        | The URI of the entry point. The maximum length is 1300 characters. Format: for `video`, `http:` or `https:` schema is required. for `phone`, `tel:` schema is required. The URI should include the entire dial sequence (e.g., tel:+12345678900,,,123456789;1234). for `sip`, `sip:` schema is required, e.g., sip:12345678@myprovider.com. for `more`, `http:` or `https:` schema is required. |          |
| `conferenceData.notes`                                    | `string`        | Additional notes (such as instructions from the domain administrator, legal notices) to display to the user. Can contain HTML. The maximum length is 2048 characters. Optional. |          |
| `conferenceData.signature`                                | `string`        | The signature of the conference data. Generated on server side. Must be preserved while copying the conference data between events, otherwise the conference data will not be copied. Unset for a conference with a failed create request. Optional for a conference with a pending create request. |          |
| `created`                                                 | `datetime`      | Creation time of the event (as a [RFC3339](https://tools.ietf.org/html/rfc3339) timestamp). Read-only. |          |
| `creator`                                                 | `object`        | The creator of the event. Read-only.                         |          |
| `creator.displayName`                                     | `string`        | The creator's name, if available.                            |          |
| `creator.email`                                           | `string`        | The creator's email address, if available.                   |          |
| `creator.id`                                              | `string`        | The creator's Profile ID, if available. It corresponds to the `id` field in the [People collection of the Google+ API](https://developers.google.com/+/web/api/rest/latest/people) |          |
| `creator.self`                                            | `boolean`       | Whether the creator corresponds to the calendar on which this copy of the event appears. Read-only. The default is False. |          |
| `description`                                             | `string`        | Description of the event. Can contain HTML. Optional.        | writable |
| `end`                                                     | `nested object` | The (exclusive) end time of the event. For a recurring event, this is the end time of the first instance. |          |
| `end.date`                                                | `date`          | The date, in the format "yyyy-mm-dd", if this is an all-day event. | writable |
| `end.dateTime`                                            | `datetime`      | The time, as a combined date-time value (formatted according to [RFC3339](https://tools.ietf.org/html/rfc3339)). A time zone offset is required unless a time zone is explicitly specified in `timeZone`. | writable |
| `end.timeZone`                                            | `string`        | The time zone in which the time is specified. (Formatted as an IANA Time Zone Database name, e.g. "Europe/Zurich".) For recurring events this field is required and specifies the time zone in which the recurrence is expanded. For single events this field is optional and indicates a custom time zone for the event start/end. | writable |
| `endTimeUnspecified`                                      | `boolean`       | Whether the end time is actually unspecified. An end time is still provided for compatibility reasons, even if this attribute is set to True. The default is False. |          |
| `etag`                                                    | `etag`          | ETag of the resource.                                        |          |
| `eventType`                                               | `string`        | Specific type of the event. Read-only. Possible values are: "`default`" - A regular event or not further specified."`outOfOffice`" - An out-of-office event. |          |
| `extendedProperties`                                      | `object`        | Extended properties of the event.                            |          |
| `extendedProperties.private`                              | `object`        | Properties that are private to the copy of the event that appears on this calendar. | writable |
| `extendedProperties.private.(key)`                        | `string`        | The name of the private property and the corresponding value. |          |
| `extendedProperties.shared`                               | `object`        | Properties that are shared between copies of the event on other attendees' calendars. | writable |
| `extendedProperties.shared.(key)`                         | `string`        | The name of the shared property and the corresponding value. |          |
| `gadget`                                                  | `object`        | A gadget that extends this event. Gadgets are deprecated; this structure is instead only used for returning birthday calendar metadata. |          |
| `gadget.display`                                          | `string`        | The gadget's display mode. Deprecated. Possible values are: "`icon`" - The gadget displays next to the event's title in the calendar view."`chip`" - The gadget displays when the event is clicked. | writable |
| `gadget.height`                                           | `integer`       | The gadget's height in pixels. The height must be an integer greater than 0. Optional. Deprecated. | writable |
| `gadget.iconLink`                                         | `string`        | The gadget's icon URL. The URL scheme must be HTTPS. Deprecated. | writable |
| `gadget.link`                                             | `string`        | The gadget's URL. The URL scheme must be HTTPS. Deprecated.  | writable |
| `gadget.preferences`                                      | `object`        | Preferences.                                                 | writable |
| `gadget.preferences.(key)`                                | `string`        | The preference name and corresponding value.                 |          |
| `gadget.title`                                            | `string`        | The gadget's title. Deprecated.                              | writable |
| `gadget.type`                                             | `string`        | The gadget's type. Deprecated.                               | writable |
| `gadget.width`                                            | `integer`       | The gadget's width in pixels. The width must be an integer greater than 0. Optional. Deprecated. | writable |
| `guestsCanInviteOthers`                                   | `boolean`       | Whether attendees other than the organizer can invite others to the event. Optional. The default is True. | writable |
| `guestsCanModify`                                         | `boolean`       | Whether attendees other than the organizer can modify the event. Optional. The default is False. | writable |
| `guestsCanSeeOtherGuests`                                 | `boolean`       | Whether attendees other than the organizer can see who the event's attendees are. Optional. The default is True. | writable |
| `hangoutLink`                                             | `string`        | An absolute link to the Google+ hangout associated with this event. Read-only. |          |
| `htmlLink`                                                | `string`        | An absolute link to this event in the Google Calendar Web UI. Read-only. |          |
| `iCalUID`                                                 | `string`        | Event unique identifier as defined in [RFC5545](https://tools.ietf.org/html/rfc5545#section-3.8.4.7). It is used to uniquely identify events accross calendaring systems and must be supplied when importing events via the [import](https://developers.google.com/calendar/v3/reference/events/import) method. Note that the `icalUID` and the `id` are not identical and only one of them should be supplied at event creation time. One difference in their semantics is that in recurring events, all occurrences of one event have different `id`s while they all share the same `icalUID`s. |          |
| `id`                                                      | `string`        | Opaque identifier of the event. When creating new single or recurring events, you can specify their IDs. Provided IDs must follow these rules: characters allowed in the ID are those used in base32hex encoding, i.e. lowercase letters a-v and digits 0-9, see section 3.1.2 in [RFC2938](http://tools.ietf.org/html/rfc2938#section-3.1.2)the length of the ID must be between 5 and 1024 charactersthe ID must be unique per calendarDue to the globally distributed nature of the system, we cannot guarantee that ID collisions will be detected at event creation time. To minimize the risk of collisions we recommend using an established UUID algorithm such as one described in [RFC4122](https://tools.ietf.org/html/rfc4122). If you do not specify an ID, it will be automatically generated by the server. Note that the `icalUID` and the `id` are not identical and only one of them should be supplied at event creation time. One difference in their semantics is that in recurring events, all occurrences of one event have different `id`s while they all share the same `icalUID`s. | writable |
| `kind`                                                    | `string`        | Type of the resource ("`calendar#event`").                   |          |
| `location`                                                | `string`        | Geographic location of the event as free-form text. Optional. | writable |
| `locked`                                                  | `boolean`       | Whether this is a locked event copy where no changes can be made to the main event fields "summary", "description", "location", "start", "end" or "recurrence". The default is False. Read-Only. |          |
| `organizer`                                               | `object`        | The organizer of the event. If the organizer is also an attendee, this is indicated with a separate entry in `attendees` with the `organizer` field set to True. To change the organizer, use the [move](https://developers.google.com/calendar/v3/reference/events/move) operation. Read-only, except when importing an event. | writable |
| `organizer.displayName`                                   | `string`        | The organizer's name, if available.                          | writable |
| `organizer.email`                                         | `string`        | The organizer's email address, if available. It must be a valid email address as per [RFC5322](https://tools.ietf.org/html/rfc5322#section-3.4). | writable |
| `organizer.id`                                            | `string`        | The organizer's Profile ID, if available. It corresponds to the `id` field in the [People collection of the Google+ API](https://developers.google.com/+/web/api/rest/latest/people) |          |
| `organizer.self`                                          | `boolean`       | Whether the organizer corresponds to the calendar on which this copy of the event appears. Read-only. The default is False. |          |
| `originalStartTime`                                       | `nested object` | For an instance of a recurring event, this is the time at which this event would start according to the recurrence data in the recurring event identified by recurringEventId. It uniquely identifies the instance within the recurring event series even if the instance was moved to a different time. Immutable. |          |
| `originalStartTime.date`                                  | `date`          | The date, in the format "yyyy-mm-dd", if this is an all-day event. | writable |
| `originalStartTime.dateTime`                              | `datetime`      | The time, as a combined date-time value (formatted according to [RFC3339](https://tools.ietf.org/html/rfc3339)). A time zone offset is required unless a time zone is explicitly specified in `timeZone`. | writable |
| `originalStartTime.timeZone`                              | `string`        | The time zone in which the time is specified. (Formatted as an IANA Time Zone Database name, e.g. "Europe/Zurich".) For recurring events this field is required and specifies the time zone in which the recurrence is expanded. For single events this field is optional and indicates a custom time zone for the event start/end. | writable |
| `privateCopy`                                             | `boolean`       | If set to True, [Event propagation](https://developers.google.com/calendar/concepts/sharing#event_propagation) is disabled. Note that it is not the same thing as [Private event properties](https://developers.google.com/calendar/concepts/sharing#private_event_properties). Optional. Immutable. The default is False. |          |
| `recurrence[]`                                            | `list`          | List of RRULE, EXRULE, RDATE and EXDATE lines for a recurring event, as specified in [RFC5545](http://tools.ietf.org/html/rfc5545#section-3.8.5). Note that DTSTART and DTEND lines are not allowed in this field; event start and end times are specified in the `start` and `end` fields. This field is omitted for single events or instances of recurring events. | writable |
| `recurringEventId`                                        | `string`        | For an instance of a recurring event, this is the `id` of the recurring event to which this instance belongs. Immutable. |          |
| `reminders`                                               | `object`        | Information about the event's reminders for the authenticated user. |          |
| `reminders.overrides[]`                                   | `list`          | If the event doesn't use the default reminders, this lists the reminders specific to the event, or, if not set, indicates that no reminders are set for this event. The maximum number of override reminders is 5. | writable |
| `reminders.overrides[].method`                            | `string`        | The method used by this reminder. Possible values are: "`email`" - Reminders are sent via email."`popup`" - Reminders are sent via a UI popup.Required when adding a reminder. | writable |
| `reminders.overrides[].minutes`                           | `integer`       | Number of minutes before the start of the event when the reminder should trigger. Valid values are between 0 and 40320 (4 weeks in minutes). Required when adding a reminder. | writable |
| `reminders.useDefault`                                    | `boolean`       | Whether the default reminders of the calendar apply to the event. | writable |
| `sequence`                                                | `integer`       | Sequence number as per iCalendar.                            | writable |
| `source`                                                  | `object`        | Source from which the event was created. For example, a web page, an email message or any document identifiable by an URL with HTTP or HTTPS scheme. Can only be seen or modified by the creator of the event. |          |
| `source.title`                                            | `string`        | Title of the source; for example a title of a web page or an email subject. | writable |
| `source.url`                                              | `string`        | URL of the source pointing to a resource. The URL scheme must be HTTP or HTTPS. | writable |
| `start`                                                   | `nested object` | The (inclusive) start time of the event. For a recurring event, this is the start time of the first instance. |          |
| `start.date`                                              | `date`          | The date, in the format "yyyy-mm-dd", if this is an all-day event. | writable |
| `start.dateTime`                                          | `datetime`      | The time, as a combined date-time value (formatted according to [RFC3339](https://tools.ietf.org/html/rfc3339)). A time zone offset is required unless a time zone is explicitly specified in `timeZone`. | writable |
| `start.timeZone`                                          | `string`        | The time zone in which the time is specified. (Formatted as an IANA Time Zone Database name, e.g. "Europe/Zurich".) For recurring events this field is required and specifies the time zone in which the recurrence is expanded. For single events this field is optional and indicates a custom time zone for the event start/end. | writable |
| `status`                                                  | `string`        | Status of the event. Optional. Possible values are: "`confirmed`" - The event is confirmed. This is the default status."`tentative`" - The event is tentatively confirmed."`cancelled`" - The event is cancelled (deleted). The [list](https://developers.google.com/calendar/v3/reference/events/list) method returns cancelled events only on incremental sync (when `syncToken` or `updatedMin` are specified) or if the `showDeleted` flag is set to `true`. The [get](https://developers.google.com/calendar/v3/reference/events/get) method always returns them. A cancelled status represents two different states depending on the event type: Cancelled exceptions of an uncancelled recurring event indicate that this instance should no longer be presented to the user. Clients should store these events for the lifetime of the parent recurring event. Cancelled exceptions are only guaranteed to have values for the `id`, `recurringEventId` and `originalStartTime` fields populated. The other fields might be empty. All other cancelled events represent deleted events. Clients should remove their locally synced copies. Such cancelled events will eventually disappear, so do not rely on them being available indefinitely. Deleted events are only guaranteed to have the `id` field populated. On the organizer's calendar, cancelled events continue to expose event details (summary, location, etc.) so that they can be restored (undeleted). Similarly, the events to which the user was invited and that they manually removed continue to provide details. However, incremental sync requests with `showDeleted` set to false will not return these details. If an event changes its organizer (for example via the [move](https://developers.google.com/calendar/v3/reference/events/move) operation) and the original organizer is not on the attendee list, it will leave behind a cancelled event where only the `id` field is guaranteed to be populated. | writable |
| `summary`                                                 | `string`        | Title of the event.                                          | writable |
| `transparency`                                            | `string`        | Whether the event blocks time on the calendar. Optional. Possible values are: "`opaque`" - Default value. The event does block time on the calendar. This is equivalent to setting **Show me as** to **Busy** in the Calendar UI."`transparent`" - The event does not block time on the calendar. This is equivalent to setting **Show me as** to **Available** in the Calendar UI. | writable |
| `updated`                                                 | `datetime`      | Last modification time of the event (as a [RFC3339](https://tools.ietf.org/html/rfc3339) timestamp). Read-only. |          |
| `visibility`                                              | `string`        | Visibility of the event. Optional. Possible values are: "`default`" - Uses the default visibility for events on the calendar. This is the default value."`public`" - The event is public and event details are visible to all readers of the calendar."`private`" - The event is private and only event attendees may view event details."`confidential`" - The event is private. This value is provided for compatibility reasons. | writable |



## Events API

These are separated just for the purpose of keeping events functions together.



### eventDelete

**Syntax:** `eventDelete (eventID:text) -> boolean`

**Summary:** Implements [Events: delete](https://developers.google.com/calendar/v3/reference/events/delete)

**Description:** Deletes the event with ID *eventID*

* If successful, **this.events** is updated, removing the event in question

**Returns:** *True* if successful, *False* if unsuccessful

**Notes:**

* Does not implement any optional parameters as described in Google's documentation




### eventsGet

**Syntax:** `eventsGet () -> boolean`

**Summary:** Implements [Events:list](https://developers.google.com/calendar/v3/reference/events/list)

**Description:** Gets all events for the calendar

​	Updates **this.events**

**Notes:**

* Does not implement any optional parameters

* Uses the calendar ID set using [setID](#setid)

* Loads ***all*** events for the calendar into the **this.events** property
  * Order is "unspecified, stable"

  * Does not include deleted events

  * Does not include hidden invitations

  * Returns recurring events in all their glory

  * Time zone is the time zone of the calendar

**Returns:**

* Returns **True** if the operation was successful and **False** if it was not.

```json
{
  "kind": "calendar#events",
  "etag": etag,
  "summary": string,
  "description": string,
  "updated": datetime,
  "timeZone": string,
  "accessRole": string,
  "defaultReminders": [
    {
      "method": string,
      "minutes": integer
    }
  ],
  "nextPageToken": string,
  "nextSyncToken": string,
  "items": [
    events Resource
  ]
}
```

**Events Resource Format**

| Property name                | Value      | Description                                                  | Notes    |
| :--------------------------- | :--------- | :----------------------------------------------------------- | :------- |
| `kind`                       | `string`   | Type of the collection ("`calendar#events`").                |          |
| `etag`                       | `etag`     | ETag of the collection.                                      |          |
| `summary`                    | `string`   | Title of the calendar. Read-only.                            |          |
| `description`                | `string`   | Description of the calendar. Read-only.                      |          |
| `updated`                    | `datetime` | Last modification time of the calendar (as a [RFC3339](https://tools.ietf.org/html/rfc3339) timestamp). Read-only. |          |
| `timeZone`                   | `string`   | The time zone of the calendar. Read-only.                    |          |
| `accessRole`                 | `string`   | The user's access role for this calendar. Read-only. Possible values are: "`none`" - The user has no access."`freeBusyReader`" - The user has read access to free/busy information."`reader`" - The user has read access to the calendar. Private events will appear to users with reader access, but event details will be hidden."`writer`" - The user has read and write access to the calendar. Private events will appear to users with writer access, and event details will be visible."`owner`" - The user has ownership of the calendar. This role has all of the permissions of the writer role with the additional ability to see and manipulate ACLs. |          |
| `defaultReminders[]`         | `list`     | The default reminders on the calendar for the authenticated user. These reminders apply to all events on this calendar that do not explicitly override them (i.e. do not have `reminders.useDefault` set to True). |          |
| `defaultReminders[].method`  | `string`   | The method used by this reminder. Possible values are: "`email`" - Reminders are sent via email."`popup`" - Reminders are sent via a UI popup.Required when adding a reminder. | writable |
| `defaultReminders[].minutes` | `integer`  | Number of minutes before the start of the event when the reminder should trigger. Valid values are between 0 and 40320 (4 weeks in minutes). Required when adding a reminder. | writable |
| `nextPageToken`              | `string`   | Token used to access the next page of this result. Omitted if no further results are available, in which case `nextSyncToken` is provided. |          |
| `items[]`                    | `list`     | List of events on the calendar.                              |          |
| `nextSyncToken`              | `string`   | Token used at a later point in time to retrieve only the entries that have changed since this result was returned. Omitted if further results are available, in which case `nextPageToken` is provided. |          |



### eventInsert

**Syntax:** `eventInsert(eventObject : Object) -> boolean`

**Summary:** Implements [Events:Insert](https://developers.google.com/calendar/v3/reference/events/insert)

**Description:** Adds *eventObject* to the calendar

* Updates **this.events**, appending the [Event Resource](https://developers.google.com/calendar/v3/reference/events#resource) to the end of the collection

* Returns **true** if successful or **false** if unsuccessful

**Notes: **

* Does not implement any optional parameters as described in Google's documentation

**Parameters:** An [Event Resource](https://developers.google.com/calendar/v3/reference/events#resource) object

* Note that **start** and **end** are *Required* properties, and all other properties are *Optional Properties*

**Returns:** **True** if successful, **False** if unsuccessful

**Example:**





## Internal Structure

#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

### Internal Properties

|Field|Datatype|Description|
|--|--|--|
| _apiKey |Text|from the Google Cloud Project Console             |
| _auth |Text|(Reference to) the authorization object created by **cGoogleAuth** |


## Internal API



### _http ( http_method:TEXT ; url:TEXT; body:TEXT; header:object )

Overrides to ***cGoogleComms._http***: if it gets a specific error that makes it suspect that the token has expired, it force-refreshes the token and then tries again.



## References
* Calendars

  https://developers.google.com/calendar

  https://developers.google.com/calendar/concepts

  https://developers.google.com/calendar/quickstart/js

  [Calendars Resource Metadata](https://developers.google.com/calendar/v3/reference/calendars#resource)

* Events

  https://developers.google.com/calendar/v3/reference/events

  https://developers.google.com/calendar/v3/reference/events#methods