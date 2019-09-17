| import './notice-templates.tag'
| import './notice-log.tag'

notice
    ul.nav.nav-tabs.m-b-2
        li.active
            a(data-toggle='tab', href='#notice-templates') Шаблоны
        li
            a(data-toggle='tab', href='#notice-log') Лог

    .tab-content
        #notice-templates.tab-pane.fade.in.active
            notice-templates
        #notice-log.tab-pane.fade
            notice-log
