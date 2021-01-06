// JavaScript that handles the dynamic ordering quantities on the ordering page.
//
// In a JavaScript block on the actual view, define the article data by calls to setData().
// You should also set the available group balance through setGroupBalance(amount).
//
// Call setDecimalSeparator(char) to overwrite the default character "." with a localized value.

var modified = false;           // indicates if anything has been clicked on this page
var groupBalance = 0;           // available group money
var minimumBalance = 0;         // minimum group balance for the order to be succesful
var toleranceIsCostly = true;   // default tolerance behaviour
var isStockit = false;          // Whether the order is from stock oder normal supplier

// Article data arrays:
var price = new Array();
var unit = new Array();              // items per order unit
var itemTotal = new Array();         // total item price
var quantityOthers = new Array();
var toleranceOthers = new Array();
var itemsAllocated = new Array();    // how many items the group has been allocated and should definitely get
var quantityAvailable = new Array(); // stock_order. how many items are currently in stock

function setToleranceBehaviour(value) {
    toleranceIsCostly = value;
}

function setStockit(value) {
    isStockit = value;
}

function setGroupBalance(amount) {
    groupBalance = amount;
}

function setMinimumBalance(amount) {
    minimumBalance = amount;
}

function addData(orderArticleId, itemPrice, itemUnit, itemSubtotal, itemQuantityOthers, itemToleranceOthers, allocated, available) {
    var i = orderArticleId;
    price[i] = itemPrice;
    unit[i] = itemUnit;
    itemTotal[i] = itemSubtotal;
    quantityOthers[i] = itemQuantityOthers;
    toleranceOthers[i] = itemToleranceOthers;
    itemsAllocated[i] = allocated;
    quantityAvailable[i] = available;
}

function increaseQuantity(item) {
    var $el   = $('#q_' + item);
    var quantity = Number($el.val()) + 1;

    update(item, quantity);
}

function decreaseQuantity(item) {
    var $el   = $('#q_' + item);
    var quantity = Number($el.val()) - 1;

    if (quantity >= 0) {
        update(item, quantity);
    }
}

function updateManually(item, quantity) {
    if ($.isNumeric(quantity) && parseInt(quantity) < 0) {
        quantity = 0;
    }

    if (quantity >= 0) {
        update(item, quantity);
    }
}

function update(item, quantity) {
    // set modification flag
    modified = true;

    $('#q_' + item).val(quantity);

    // calculate how many units would be ordered in total
    var units = calcUnits(quantityOthers[item] + Number(quantity), unit[item]);

    $('#units_' + item).html(units);
    $('#q_total_' + item).html(Number(quantity) + quantityOthers[item]);

    // update total price
    itemTotal[item] = price[item] * Number(quantity);
    $('#price_' + item + '_display').html(I18n.l("currency", itemTotal[item]));

    updateBalance();
    updateButtons($('#q_' + item).closest('tr'));
}

function calcUnits(quantity, unitSize) {
    return Math.ceil(quantity / unitSize);
}

function updateBalance() {
    // update total price and order balance
    var total = 0;
    for (i in itemTotal) {
        total += itemTotal[i];
    }
    $('#total_price').html(I18n.l("currency", total));
    var balance = groupBalance - total;
    $('#new_balance').html(I18n.l("currency", balance));
    $('#total_balance').val(I18n.l("currency", balance));
    // determine bgcolor and submit button state according to balance
    var bgcolor = '';
    if (balance < minimumBalance) {
        bgcolor = '#FF0000';
        $('#submit_button').attr('disabled', 'disabled')
    } else {
        $('#submit_button').removeAttr('disabled')
    }
    // update bgcolor
    for (i in itemTotal) {
        $('#td_price_' + i).css('background-color', bgcolor);
    }
}

function updateButtons($el) {
    // enable/disable buttons
    $el.find('a.decrease-quantity').each(function() {
      var $q = $el.find('#q_' + $(this).data('order-article-id'));
      $(this).toggleClass('disabled', $q.val() <= 0);
    });
}

$(function() {
    $('input.quantity').on('keyup change', function() {
        updateManually($(this).data('order-article-id'), $(this).val());
    });

    $('a.increase-quantity').on('touchclick', function() {
        increaseQuantity($(this).data('order-article-id'));
    });

    $('a.decrease-quantity').on('touchclick', function() {
        decreaseQuantity($(this).data('order-article-id'));
    });

    $('a[data-confirm_switch_order]').on('touchclick', function() {
        return (!modified || confirm(I18n.t('js.ordering.confirm_change')));
    });

    updateButtons($(document));
});
