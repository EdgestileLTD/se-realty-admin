| import 'pages/objects/location-list.tag'
| import 'pages/objects/location-edit.tag'
| import 'pages/objects/object-list.tag'
| import 'pages/objects/object-edit.tag'
| import 'pages/objects/object-types.tag'
| import 'pages/objects/object-types-edit.tag'
| import 'pages/objects/object-map-edit.tag'
| import 'pages/objects/object-items-edit.tag'
| import 'pages/objects/object-edit-images.tag'
| import 'pages/objects/object-edit-files.tag'
| import 'pages/objects/labels/labels-list.tag'
| import 'pages/objects/labels/label-edit.tag'
| import 'pages/objects/location-event-edit.tag'

objects
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }')
            a(href='#objects/{ link }')
                span { title }

    .column
        object-list(if='{ tab == "objects" && !edit }')
        object-edit(if='{ tab == "objects" && edit }')

        location-list(if='{ tab == "location" && !edit }')
        location-edit(if='{ tab == "location" && edit }')

        labels-list(if='{ tab == "labels" && !edit }')
        label-edit(if='{ tab == "labels" && edit }')
        location-event-edit(if='{ tab == "events" && edit }')


        object-types(if='{ tab == "types" && !edit }')
        object-types-edit(if='{ tab == "types" && edit }')
        object-map-edit(if='{ tab == "maps" }')
        object-items-edit(if='{ tab == "items" }')

    style.
        treenodes .treenode {
            padding: 5px;
        }

    script(type='text/babel').
        var self = this

        self.edit = false
        self.tab = ''

        self.tabs = [
            {title: 'Список объектов', name: 'objects', link: ''},
            {title: 'Адреса', name: 'location', link: 'location'},
            {title: 'Ярлыки', name: 'labels', link: 'labels'},
        ]

        var route = riot.route.create()

        route('/objects/([0-9]+)', id => {
            self.tab = 'objects'
            observable.trigger('objects-edit', id)
            self.edit = true
            self.update()
        })

        route('/objects/maps/([0-9]+)/clone', id => {
           // self.tab = 'objects'
           // observable.trigger('object-map-clone', id)
           // self.update({edit: true, tab: 'maps'})
        })

        route('/objects/*/([0-9]+)', (tab, id) => {
            if (tab == 'location') {
                observable.trigger('location-edit', id)
                self.update({edit: true, tab: 'location'})
            } else
            if (tab == 'maps') {
                self.tab = 'objects'
                observable.trigger('object-map-edit', id)
                self.update({edit: true, tab: 'maps'})
            } else
            if (tab == 'events') {
                observable.trigger('location-event-edit', id)
                self.update({edit: true, tab: 'events'})
            } else
            if (tab == 'items') {
                self.tab = 'objects'
                observable.trigger('object-items-edit', id)
                self.update({edit: true, tab: 'items'})
            } else
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })


        route('/objects/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'objects'
            observable.trigger('object-multi-edit', ids)
            self.edit = true
            self.update()
        })

        route('/objects/clone..', () => {
            let q = riot.route.query()
            let id = q.id
            self.tab = 'objects'
            observable.trigger('object-clone', id)
            self.edit = true
            self.update()
        })

        route('/objects/types/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'types'
            observable.trigger('object-types-multi-edit', ids)
            self.edit = true
            self.update()
        })


        route('/objects/labels/new', tab => {
            self.update({edit: true, tab: 'labels'})
            observable.trigger('label-new')
        })

        //route('/objects/items/new', tab => {
        //    self.update({edit: true, tab: 'items'})
        //    observable.trigger('object-items-edit', 0)
        //})


        route('/objects', () => {
            self.edit = false
            self.tab = 'objects'
            self.update()
        })

        route('/objects/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/objects..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })
