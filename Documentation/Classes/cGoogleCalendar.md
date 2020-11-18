# Class cGoogleCalendar



## Description

Class for accessing and updating google calendars.

Extends *cGoogleComms*, **but** there should be at least one *cGoogleComms* object created separately that will be the "master".  Authorization header data should be copied from that object to the others.  Authorization headers should be checked periodically to see if they have expired or have been revoked, and then the new data shared after the authorization is renewed.



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



## Public Properties

Property|Datatype|Description
--|--|--
status|Integer|http status
error|object|http error object (if status <>200)



## API

### createCalendar( calendarName: text) -> boolean

* Implements [Calenders:insert](https://developers.google.com/calendar/v3/reference/calendars/insert).
* If the result is successful, **true** is returned and the calendar's metadata is loaded into the private property **this._properties**.
* If the result is unsuccessful then **false** is returned, and **this.error** will have the error object.



The **this._properties** is an instance of [Calendars Resource](https://developers.google.com/calendar/v3/reference/calendars#resource):

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



#### Example:

```4d
if not($calendar.createCalendar("test")) // fail
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
   ABORT
End If
```



### eventDelete (eventID:text) -> boolean

Implements [Events: delete](https://developers.google.com/calendar/v3/reference/events/delete)

* Does not implement any optional parameters
* If successful, **this._events** is updated, removing the event in question
* Returns **True** if delete was successful and **False** if it was not.



### getCalendarList () -> object

Implements [CalendarList: list](https://developers.google.com/calendar/v3/reference/calendarList/list), but ***does not implement any of the optional parameters***.

* Currently will only retrieve the first 100 calendars.
* Returns only non-deleted non-hidden calendars that the account in the *cGoogleAuth.Username* object can see.  For more information, see the **cGoogleAuth** class documentation.
* Does not pull the *syncToken* which is a timestamp of sorts that can be used to query Google for updates since the calendar info was retrieved.



#### Return object:

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

#### Items List Format

```
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



#### Example:

```4d
$calendarList:=$calendar.getCalendarList()
$id:=$calendar.items[0].id
```



### getEvents () -> boolean

Implements [Events:list](https://developers.google.com/calendar/v3/reference/events/list)

* Does not implement any optional parameters

* Uses the calendar ID set using [setID](#setid)
* Loads ***all*** events for the calendar into the private **this._events** property
  * Order is "unspecified, stable"
  * Does not include deleted events
  * Does not include hidden invitations
  * Returns recurring events in all their glory
  * Time zone is the time zone of the calendar
* Returns **True** if the operation was successful and **False** if it was not.

```
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

#### Events Resource Format
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



### setID ( calendarID : text ) -> $idIsAValidCalendar:boolean

* Sets the private **this._properties.ID** of the *cGoogleCalendar* object to the ID passed in **calendarID**
* Checks to see if ID is a valid calendar, and returns a boolean indicating that it is or is not.
* If ID is a valid calendar, loads the calender properties into the private **this._properties** property per [Calendars: get](https://developers.google.com/calendar/v3/reference/calendars/get)

#### Exampe:

```4d
$valid:=$cal.setID($calendarID)
If (not($valid))
   Alert ("That is not a valid calendar id.")
End if
```



## Internal Structure

#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

### Internal Properties

|Field|Datatype|Description|
|--|--|--|
| _apiKey |Text|from the Google Cloud Project Console             |
| _auth |Text|(Reference to) the authorization object created by **cGoogleAuth** |
| _properties |Object|The [Calendars Resource](https://developers.google.com/calendar/v3/reference/calendars#resource) metadata for the calendar assigned to **this** |
| _events     |Object| |



## Internal API



### _http ( http_method:TEXT ; url:TEXT; body:TEXT; header:object )

Overrides to ***cGoogleComms._http***: if it gets a specific error that makes it suspect that the token has expired, it force-refreshes the token and then tries again.



## References
https://developers.google.com/calendar

https://developers.google.com/calendar/quickstart/js

[Calendars Resource Metadata](https://developers.google.com/calendar/v3/reference/calendars#resource)