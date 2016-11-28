#DJNRO

##Overview
A definition of requirements applicable to the DjNRO project to support the Xeap project.
These requirements specify what is required over and above the functionality already present in the djnro project.

##Background
The DjNRO project aims to simplify the administration required by federation members.
It is developed primarily by staff at GRNET (NREN of Greece), and is in use at various national roaming organisations internationally.
The web site has more information which may be useful: http://djnro.grnet.gr/

The supporting specification document is held in google docs.
This document holds more detailed background information.
https://drive.google.com/open?id=0B3PaqnzL5H9uTlJac3ZxaS1oLUk

##Questions

- Virtual machine infrastructure on the deployment machine - what is it, vmware?

- Who provides the mail (SMTP) infrastructure required to send notifictions from djnro?

##Functionality

###Modified model

The current data model assumes an institution has a flat arrangement of RADIUS servers and access points.
It also assumes that an institution manages it's own infrastructure.

To achieve flexibility detailed in the spec document, the data model:
- Needs to provide a relationship between organisations, this will support relationships:
    - between an institution and a third party hosting their radius server(s)
    - between two institutions where one institution is the federation proxy for the other
- Needs to provide a relationship between radius servers in the above proxy scenario, access points are assumed to be related to a single RADIUS tier.
This may have large implications for the user interface, see that section for details.

Modifications are also required to add an entity to track the software used for identity management (e.g. OpenLDAP, etc) and for RADIUS itself, so:
- A radius server entity needs to be present that details the software package and version used
- A identity store entity needs to be present that details the software package and version used
The above should be normalised into a software release table if deemed appropriate.

The spec document mentions the need for an Idp only radius server, this may already be implemented:
https://github.com/grnet/djnro/blob/master/edumanage/models.py#L101

###Deployment
Deployment needs to be scripted.
Documentation should be limited (where practicle) to setting up an environment required to execute the scripted deployment.

Where possible Docker will be used to provide an immutable deployment of software required for DjNRO, this would include:
- An application server
- A database server
- A front end webserver (Apache or Nginx)

##External interfaces
The server software would require access on port 443 and 80 to the general internet.
These host public ports will be bound to container private ports.

##Performance
The request level is exepected to be low.
Due to this, it is expected that no modifications will be required to the stock djnro to address performance expectations.

##Attributes

###User Interface

The term djnro will be replaced with a new name - _admin tool_
**TODO** - this name does not describe what the tool is an admin of / it's purpose.

Use the term _Country_ in place of _Realm_.
**TODO** - Does this refer to just the user interface or the data model.
This might break behaviour with the upstream in the case of the data model.

The django admin interface is to be modified to clearly denote that the interface is for NRO admin.

The changes to the data model (detailed above) require a new user interface to support the relationships described.
My gut feeling at this stage is that this is a significant amount of work.
**TODO** this has the potential to be a big piece of work.

###Security
- There is a concern raised by a reasearcher (via Stefan Winter) that the federation can be expanded arbitrarily by and Idp admin.
This could be mitigated by requiring that each material modification be authorised by the NRO?

**TODO** I am not sure this represents a real risk to the NRO, this is after all what the tool is designed to do.
This concern is somewhat exhaserbated by the requirement to allow a hierarchy to be formed by members of the federation.

- Confirm that the admin interface is sufficiently secure.
**TODO** Who is determining what consitutes _sufficient_?

###Localisation

An english language user interface is required.
The upstream djnro repository uses greek for the user interface, with no i18n provision for english.

##Design constraints imposed on an implementation
Are there any required standards in effect, implementation language, policies for database integrity, resource limits, operating environment(s) etc.?

