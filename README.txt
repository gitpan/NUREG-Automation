noch ein paar Ideen:
--------------------

#include "indesign_utils.js"

  // standard initialization
Application.prototype['stdInit']     = function() {};

  // close all docs
Application.prototype['closeAll']    = function() {};

  // get pageitems matching a tag
PageItem.prototype['taggedElements'] = function(tag:string): PageItems {};


-------------

