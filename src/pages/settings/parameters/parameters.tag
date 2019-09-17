| import 'pages/settings/parameters/parameters-list.tag'
| import 'pages/settings/parameters/parameters-groups-list.tag'
parameters
    ul.nav.nav-tabs.m-b-2
        li.active: a(data-toggle='tab', href='#parameters-list') Список параметров
        li: a(data-toggle='tab', href='#parameters-group') Группы

    .tab-content
        #parameters-list.tab-pane.fade.in.active
            parameters-list

        #parameters-group.tab-pane.fade
            parameters-groups-list