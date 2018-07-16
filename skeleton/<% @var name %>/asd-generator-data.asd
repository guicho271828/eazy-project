#|
  This file is a part of <% @var name %> project.

This is a [asd-generator](https://github.com/phoe/asd-generator/) config file.
Run below for auto-regenerating the asd file:

$ ros install phoe/asd-generator
$ update-asdf

<% @if author %>  Copyright (c) <%= (local-time:timestamp-year (local-time:now)) %> <% @var author %><% @if email %> (<% @var email %>)<% @endif %>
<% @endif %>|#
<%
(when (or (getf env :description)
          (getf env :author))
%>
#|<% @if description %>
  <% @var description %><% @endif %><% @if author %>
<% (when (and (getf env :description) (getf env :author)) %>
<% ) %>  Author: <% @var author %><% @if email %> (<% @var email %>)<% @endif %><% @endif %>
|#
<% ) %>

((:dir :src
       (:package)
       (:rest)))

