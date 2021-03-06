"use strict";

/*global mediaWiki, jQuery*/

/*
 Adds some helper functions to the mw object:
 * getHrefWithUpdatedQueryString
 * getQueryParam
 * updatedQueryString
*/
(function(mw, $) {
    mw.isCategoryPage = mw.config.values.wgNamespaceNumber === mw.config.values.wgNamespaceIds.category;
    mw.viewingCategoryPage = mw.isCategoryPage && mw.config.values.wgAction === 'view';

    var a = document.createElement('a'),

	qsParts = function(a) {
	    // Remove leading '?'
	    return a.search.substring(1)
		.split('&');
	},

	validQSPiece = function(k, v) {
	    return !(
		k === undefined || k === 'null' || k === 'undefined' || k === '' ||
		    v === undefined || v === 'null' || v === 'undefined' || v === ''
	    );
	};

    /*
     Gets the href of the current window. Changes it to include the specified query string paramed. Returns the result as a string.
    */
    mw.getHrefWithUpdatedQueryString = function(param, value) {
	return mw.updatedQueryString(window.location.href, param, value);
    };

    /*
     Given a URL and a query string parameter to search for, find the value of that query string.

     If multiple, this will be an array.
     If empty, this will be null.
    */
    mw.getQueryParam = function(url, param) {
	a.href = url;

	if (a.search.length === 0) {
	    return null;
	} else {
	    var values = [],
		parts = qsParts(a);

	    parts.forEach(function(p) {
		var pieces = p.split('=');

		if (pieces[0] === param) {
		    values.push(pieces[1]);
		}
	    });

	    switch (values.length) {
	    case 0:
		return null;
	    case 1:
		return values[0];
	    default:
		return values;
	    }
	}
    };

    /*
     A function which modifies the query string by setting one parameter to a single value.

     Any other instances of setting that parameter will be removed/replaced.
     */
    mw.updatedQueryString = function(url, param, value) {

	var fragment = encodeURIComponent(param) + '=' + encodeURIComponent(value);

	a.href = url;

	if (a.search.length === 0) {
	    a.search = '?' + fragment;
	} else {
	    var didReplace = false,

		parts = qsParts(a),

		reassemble = [];

	    parts.forEach(function(p) {
		var pieces = p.split('=');
		if (pieces[0] === param) {
		    if (!didReplace) {
			reassemble.push(fragment);
			didReplace = true;
		    }
		} else if (validQSPiece(pieces[0], pieces[1])) {
		    reassemble.push(p);
		}
	    });

	    if (!didReplace) {
		reassemble.push(fragment);
	    }

	    a.search = '?' + reassemble.join('&');
	}

	return a.href;
    };
    
}(mediaWiki, jQuery));
