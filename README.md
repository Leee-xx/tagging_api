# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
ruby 2.2.6p396

* How to run the test suite
rake spec

* Notes
I've abstracted all the requested endpoints through the TagsController to make maintenance easier,
since everything is one place.

The POST /tag endpoint creates an entity if it doesn't already exist, the reason being that a POST
is expected to create objects, and the client probably doesn't want a separate request to create
the entity.

For the DELETE endpoint, I decided to destroy the EntityTagAssociations rather than the Tags
themselves, since other entities may still use the Tags included in the deleted entity, and we
wouldn't want to affect the tagging for those other entities.

I added optional parameters to GET /stats to support pagination, and changed the response to
reflect pagination.