| import 'pages/settings/settings-main.tag'
| import 'pages/settings/parameters/parameters.tag'
| import 'pages/settings/parameters/parameter-edit.tag'
| import 'pages/settings/typeobj/typeobj-list.tag'
| import 'pages/settings/typeobj/typeobj-edit.tag'
| import 'pages/settings/notice/notice.tag'
| import 'pages/settings/notice/notice-edit.tag'

settings
    .row
        .col-sm-2.hidden-xs(if='{ !edit }')
            ul.nav.nav-pills.nav-stacked(style='height: calc(100vh - 65px); position: fixed; overflow-y: auto; padding-right: 20px; width: 15%;')
                li(each='{ tabs }', if='{ admin ? isAdmin() : checkPermission(permission, 1000) }', class='{ active: name == tab }')
                    a(href='#settings/{ link }') { title }

        .col-xs-12.hidden-sm.hidden-lg.hidden-md.form-group(if='{ !edit }')
            select.form-control(onchange='{ menuSelect }')
                option(each='{ tabs }', if='{ admin ? isAdmin() : checkPermission(permission, 1000) }',
                value='{ name }', selected='{ name == tab }', no-reorder) { title }

        .col-sm-10.col-xs-12
            .h4.text-center(if='{ tab == "" }') Выберите категорию
            //settings-main(if='{ tab == "main" }')
            parameters(if='{ tab == "parameter" && !edit }')
            typeobj-list(if='{ tab == "typeobj" && !edit }')
            notice(if='{ tab == "notice" && !edit }')

        .col-md-12
            parameter-edit(if='{ tab == "parameter" && edit }')
            typeobj-edit(if='{ tab == "typeobj" && edit }')
            notice-edit(if='{ tab == "notice" && edit }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.mixin('permissions')
        self.tab = ''

        route('/settings', () => {
            //self.edit = false
            riot.route(`/settings/typeobj`)
            //self.tab = ''
            //self.update()
        })


        route('/settings/*', tab => {
            let idx = self.tabs.map(item => item.name).indexOf(tab)
            let value
            if (idx !== -1 )
                value = self.tabs[idx].admin ? self.isAdmin() : self.checkPermission(self.tabs[idx].permission, 1000)
            if (idx !== -1 && value) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/settings/*/([0-9]+)', (tab, id) => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/settings/parameter/new', tab => {
            self.update({edit: true, tab: 'parameter'})
            observable.trigger('parameter-new')
        })

        route('/settings/typeobj/new', tab => {
            self.update({edit: true, tab: 'typeobj'})
            observable.trigger('typeobj-new')
        })

        route('/settings/notice/new', tab => {
            self.update({edit: true, tab: 'notice'})
            observable.trigger('notice-new')
        })

        route('/settings..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.tab = ''
        self.tabs = [
           // {title: 'Настройки сайта', name: 'main', link: 'main'},
            {title: 'Параметры', name: 'parameter', link: 'parameter'},
            {title: 'Типы объектов', name: 'typeobj', link: 'typeobj'},
            {title: 'Уведомления', name: 'notice', link: 'notice'},
        ]


        self.on('mount', () => {
            riot.route.exec()
        })