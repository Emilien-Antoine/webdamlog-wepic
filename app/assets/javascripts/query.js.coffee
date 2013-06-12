# Place all th0 behaviorules and hooks related  descrto the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#function addColumnFields(index) {
#  document.getElementById("column_fields").innerHTML += 
#     "Column Name : <input id=\"col" + index + "\" name=\"col" + index + "\" type=\"text\"/><br/>" +
#     "Column Type : <input id=\"type" + index + "\" name=\"type" + index + "\" type=\"text\"/>";
#}

#TODO remove need for description


jQuery.noConflict()
current_url = location.protocol + '//' + location.host + location.pathname

Object.size = (obj) ->
    size = 0
    for key of obj
        if (obj.hasOwnProperty(key))
          size++
    size

display_error = (error_msg) ->
  "The following error has been encountered : " + JSON.stringify(error_msg)


getRelationFields = (relation) ->
  jQuery.ajax
    'url' : current_url + '/relation'
    'data' :
      'relation' : relation
      'content' : false
    'datatype' : 'json'
    'success' : (data) -> 
      if data[0]
        data = data[0]
        columns = data.columns
        html = '' 
        for col in columns
          input = '<input type="text" size="30" placeholder="'+typeof(col)+'" name="'+String(col)+'">'
          html += '<div class="field">'+String(col)+':'+input+'</div>'
        jQuery('#relation_select').after(html)

getRelationContents = (relation,type)->
  jQuery('#display_relation_'+type).html('')
  jQuery.ajax
    'url' : current_url + '/relation'
    'data' :
      'relation' : relation
      'content' : true
    'datatype' : 'json'
    'success' : (data) -> 
      if data[0]
        data = data[0]
        columns = data.columns
        num = Object.size(columns)
        width =  Math.round(document.getElementById("display_relation_"+type).offsetWidth / num) - 17 + num
        html = '<tr class="record">' 
        for col in columns
          html += '<td class="attribute" style="width:'+String(width)+'px;border-bottom:1px solid #fff;font-weight:bold;">'+String(col)+'</td>'
        html += '</tr>'        
        for tuple in data.content
          html += '<tr class="record">' 
          for col,field of tuple
            html += '<td class="attribute" style="width:'+String(width)+'px;">'+String(field)+'</td>'
          html += '</tr>'
        jQuery('#display_relation_'+type).append('<table>'+html+'</table>')
        true

add_described_rule = (rule,description,role) ->
  # jQuery('#notice').html('rule:' + rule + ",description: " + description + ",role: " + role)
  # jQuery('#notice').css
    # 'display' : 'block'
  jQuery.ajax
    'url' : current_url + '/described_rule/add'
    'data' :
      'rule' : rule
      'description' : description
      'role' : role
    'datatype' : 'json'
    'success' : (data) ->
      if data.saved
        html = '<div class="drule">'
        html += '<a class="close" onclick="window.close_rule('+data.id+');">x</a>'
        html += '<div class="description">' + description+ '</div>'
        html += '<div class="id">'+data.id+'</div>'
        html += '<div class="rule">' + rule + '</div>'
        html += '</div>'
        jQuery('.'+role+'_examples').append(html)
        jQuery('#description_edit_'+role).val('')
        jQuery('#rule_edit_'+role).val('')
      else
        alert(display_error(data.errors))


remove_described_rule = (id) ->
  # jQuery('#notice').html('rule:' + rule + ",description: " + description + ",role: " + role)
  # jQuery('#notice').css
    # 'display' : 'block'
  jQuery.ajax
    'url' : current_url + '/described_rule/remove'
    'data' :
      'id' : id
    'datatype' : 'json'
    'success' : (data) ->
      if data.saved
        jQuery('.id:contains("'+String(id)+'")').parent().remove()

window.relation_refresh = (type)->
  relation = jQuery('#relation_'+type+' option:selected').html()
  getRelationContents(relation,type)

jQuery(document).ready ->
  jQuery('#relation_select').change ->
    relation = jQuery('#relation_select option:selected').html()
    if relation!='Select Relation'
      getRelationFields(relation)
    
  jQuery('#relation_extensional').change ->
    relation = jQuery('#relation_extensional option:selected').html()
    getRelationContents(relation,'extensional')
  jQuery('#relation_intentional').change ->
    relation = jQuery('#relation_intentional option:selected').html()
    getRelationContents(relation,'intentional')
  window.custom_query = ->
    rule = jQuery('#rule_edit_query').val()
    desc = jQuery('#description_edit_query').val()
    add_described_rule(rule,desc,'query')
  window.custom_update = ->
    rule = jQuery('#rule_edit_update').val()
    desc = jQuery('#description_edit_update').val()
    add_described_rule(rule,desc,'update')
  window.close_rule = (id) ->
    remove_described_rule(id)

  jQuery('#update_examples_button').click ->
    if menu_open
      menu_open = false
    else
      html = '+<div id="update_examples_menu" class="popUpMenu">'
      html += '<a type="submit" id="update_examples_menu_close" class="button-close"></a><ul>'
      html += '<li><a type="submit" id="create_relation_button" class="active_action">Create Relation...</a></li>'
      html += '<li><a type="submit" id="insert_tuple_button" class="active_action" >Insert Fact...</a></li>'
      html += '</ul></div>'
      jQuery('#update_examples_button').html(html)
      menu_open = true
      jQuery('#update_examples_menu_close').click ->
        jQuery('#update_examples_button').html('+')
        menu_open = false
      jQuery('#create_relation_button').click ->
        jQuery('#update_examples_button').html('+')
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#create_relation').css
          'display' : 'block'
        menu_open = false
      jQuery('#insert_tuple_button').click ->
        jQuery('#update_examples_button').html('+')
        jQuery('.box_wrapper').css 
          'display' : 'block'
        jQuery('#insert_tuple').css
          'display' : 'block'
        menu_open = false