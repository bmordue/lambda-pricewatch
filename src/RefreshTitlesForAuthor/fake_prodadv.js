
//var config = require('./config');
//var log = require('./log');
var needle = require('needle');
var fs = require('fs');
var cheerio = require('cheerio');
var util = require('util');
//var StatsD = require('node-statsd');

//var statsd = new StatsD({
//	prefix: 'amzn_recs.fake_prodadv.',
//	host: process.env.STATSD_HOST || 'localhost'
//});

const api_endpoint = process.env.AMZN_ENDPOINT || 'https://www.amazon.co.uk/gp/product/';

var workOffline = process.env.OFFLINE;


const log = {
  info: console.log,
  debug: console.log,
  warn: console.log,
  error: console.log
};

module.exports = function(query, params, callback) {

	log.debug({query: query, params: params}, 'Query using fake prodadv');

	var asin = params.ItemId;
	if (asin) {

	switch (query) {
		case 'SimilarityLookup':
			return similarityLookup(asin, callback);
		case 'ItemSearch':
			return itemSearch(asin, callback);
		case 'ItemLookup':
			return itemLookup(asin, callback);
		default:
			return callback(new Error('Unrecognised query term: ' + query));
	}
	}

	let author = params.Author;
	if (author) {
		return titlesForAuthor(author, callback);
	}
}

function similarityLookup(asin, callback) {
	var filename = config.get('HTML_DUMP_DIR') + asin + '_dump.html';
	if (fs.existsSync(filename)) {
		log.debug(filename, 'using cached file for similarity lookup');
		var data = fs.readFileSync(filename);
		return processDataForSimilarityLookup(data, callback);
	} else if (!workOffline) {
		log.debug(asin, 'making amzn request for similarity lookup');
		amznRequest(asin, function(err, respBody) {
			if (err) { return callback(err); }
			return processDataForSimilarityLookup(respBody, callback);
		});
	} else {
		log.debug(asin, 'skipping similarity lookup');
		return callback(null, {Items: {Item: []}});
	}
}

function processDataForSimilarityLookup(data, callback) {
		const $ = cheerio.load(data);
		var carouselElement = $('div.similarities-aui-carousel')
		if (!carouselElement) {
			log.info({}, 'did not manage to find similar items carousel in page');
			return callback(null, {});
		}
		var carouselOptions = carouselElement.attr('data-a-carousel-options');
		if (!carouselOptions) {
			log.info({}, 'did not manage to find expected attribute on similar items carousel');
			return callback(null, {});
		}
		try {
			var carousel = JSON.parse(carouselOptions.replace('\"', '"'));
		} catch (e) {
			log.debug(carouselOptions, 'carouselOptions');
			return callback(null, {'Items': {'Item': items}});
		}
		var almostAsins = carousel.ajax.id_list;
		if (!almostAsins) {
			log.info(carousel, 'did not manage to extract ASINs from carousel data');
			return callback(null, {});
		}
		var items = almostAsins.map(function(i) { return { 'ASIN': i.substring(0, i.length - 1), 'ItemAttributes': {} } }); // strip trailing colon from asins
		log.debug(items.length, 'found similar items');

		callback(null, {'Items': {'Item': items}});
}

function itemSearch(asin, callback) {
	log.warn(asin, 'skipped itemSearch(), not yet implemented');
	return callback(new Error('Not yet implemented'));
}

function itemLookup(asin, callback) {
	var filename = config.get('HTML_DUMP_DIR') + asin + '_dump.html';
	if (fs.existsSync(filename)) {
		log.debug(filename, 'using cached file for item lookup');
		var data = fs.readFileSync(filename);
		return processDataForItemLookup(asin, data, callback);
	} else if (!workOffline) {
		log.debug(asin, 'making amzn request for item lookup');
		amznRequest(asin, function(err, respBody) {
			if (err) { return callback(err); }
			return processDataForItemLookup(asin, respBody, callback);
		});
	} else {
		log.debug(asin, 'skipping item lookup');
		return callback(null, {Items: {Item: []}});
	}
}

function processDataForItemLookup(asin, data, callback) {
	var result = {
		Items: {
			Item: {
				ASIN: 0,
				DetailPageURL: '',
				ItemAttributes: {
					Title: '',
					Author: '',
					ListPrice: {
						Amount: 0,
						CurrencyCode: 'GBP'
					}
				}
			}
		}
	};

	const $ = cheerio.load(data);

	var title = $('#ebooksProductTitle').text();
	result.Items.Item.ItemAttributes.Title = title;

	var currencyCode = $('#buyOneClick input[name="displayedCurrencyCode"]').attr('value');
	result.Items.Item.ItemAttributes.ListPrice.CurrencyCode = currencyCode;

	var price = $('#buyOneClick input[name="displayedPrice"]').attr('value');
	result.Items.Item.ItemAttributes.ListPrice.Amount = price * 100;

	var authors = [];
	$('a[data-asin]').each(function(ie, el) {
		authors.push(($(el).text()));
	});
	log.debug({authors: authors}, 'authors');
	result.Items.Item.ItemAttributes.Author = authors;

	result.Items.Item.DetailPageUrl = api_endpoint + asin;
	result.Items.Item.ASIN = asin;

	return callback(null, result);
}

function amznRequest(asin, callback) {
	// https://www.amazon.co.uk/gp/product/B003GK21A8
	var reqUrl = api_endpoint + asin;
	var options = {};
	options.proxy = null; // Or eg 'http://localhost:8888'

	needle.get(reqUrl, options, function(err, result) {
		if (err) {
			return callback(err);
		}
		statsd.increment(result.statusCode);
		if (result.statusCode == 503) {
			log.warn({}, 'Going offline; fake_prodadv will stop making requests to amzn');
			workOffline = true;
		}
		if (result.statusCode != 200) {
			log.error({}, 'Response code is ' + result.statusCode);
			return callback({code: result.statusCode, message: 'amzn request failed'});
		}
		if (!result.body) {
			return callback(new Error('No response body'));
		}

		var filename = config.get('HTML_DUMP_DIR') + asin + '_dump.html';
		fs.writeFileSync(filename, result.body);

		callback(null, result.body);
	});
}

//function parseResultItem(index, jqItem) {
//}


function matchAuthor(expected, actual) {
	// TODO: add fuzzier matching, eg Iain M Banks, Iain Banks
	return expected == actual;
}


function titlesForAuthor(author, callback) {
	const urlTemplate = "https://www.amazon.co.uk/s?k=%s&rh=n%3A341677031&dc&qid=1569572181&rnid=1642204031&ref=is_r_n_2";
	const reqUrl = util.format(urlTemplate, author.replace(' ', '+'));
	const options = {};

	needle.get(reqUrl, options, function(err, result) {
		if (err) return callback(err);
		log.debug(result.statusCode, "Fetched query result");
		fs.writeFileSync("titlesForAuthor.scratch.html", result.body);

		const $ = cheerio.load(result.body);
		const resultsCountStr = $(".s-mobile-toolbar > .s-line-clamp-2 > div > span > span").first().text().trim();
		log.debug(util.inspect(resultsCountStr), "Extracted results count");
		let resultsCount = 0;
		if (resultsCountStr) {
			try { resultsCount = resultsCountStr.parseInt(); } catch (e) { log.debug(resultsCountStr, "Could not parse results count as int"); }
		}
		//$("div.s-result-list").childElementCount;
		const resultsPerPage = 17;
		const totalPages = Math.floor(resultsCount / resultsPerPage) + 1;

		let pageOfItems = [];

//		const resultsListSel = "div.s-result-list > div";
//		const detailsSel = "div > span > div > div > div > div > div > a"; // rel to resultsListSel
//		const titleSel = "div > h2"; // rel to detailsSel


		$("div.s-result-list > div").each(function(index, element) {
			if (index > 0) return;
//			if (index == 0) {log.debug(util.inspect(element, null, 2)); }
//			log.debug(element.attribs["data-asin"], "data-asin");
			log.debug($(this).attr("data-asin"), "also data-asin");
//			log.debug($(this).text(), "this.text()");
// div.s-result-list > div:nth-child(1) ^^^ div > span > div > div ^^ div > div > div > a > div > h2 > span
			let details = $(this, "div > span > div > div > div > div > div > a");
			log.debug(details.attr("title"), "attr(title)");
//			log.debug(details.text().trim(), "details.text");
//			log.debug(util.inspect(details, null, 3), "details");
//			log.debug(details.text(), "details.text()");
			let resultItemTitle = $("div > h2", details).text().trim();
			log.debug($("div", details).text().trim(), "details > div .text()");
			let resultItemAuthor = $("div > div > span:nth-child(2)", details).text().trim(); // check this against author param
			let resultItemEdition = $("div:nth-child(3) > div", details).text().trim(); // should be "Kindle Edition"
			let resultItemPrice = $("div:nth-child(3) > div:nth-child(2) > div > span", details).text().trim();
			// any other details -- eg, item direct URL? ASIN!

			let itemDetails = {Author: resultItemAuthor, Title: resultItemTitle, Price: resultItemPrice};
			log.debug(itemDetails, "itemDetails");

			// validate author and edition
			if (!matchAuthor(author, resultItemAuthor)) {
				log.debug(util.format("Ignoring item: author mismatch (%s vs %s)", author, resultItemAuthor));
			} else if (resultItemEdition.trim() != "Kindle Edition") {
				log.debug(util.format("Ignoring item: does not appear to be Kindle Edition (%s)", resultItemEdition));
			} else {
				pageOfItems.push(itemDetails);
			}
		});

		console.log(util.format("totalPages: %s; resultsCount: %s", totalPages, resultsCount));

		callback(null, { Items: { TotalPages: totalPages, TotalResults: resultsCount,  Item: pageOfItems } });
	});

}
