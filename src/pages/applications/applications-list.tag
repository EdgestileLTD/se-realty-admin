applications-list
    catalog(object='Application', search='true', cols='{ cols }', dblclick='{ edit }', remove='{ remove }', reload='true',
    sortable='true')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='date') { moment(row.date).format('llll') == 'Invalid date' ? '-' : moment(row.date).format('llll') }
            datatable-cell(name='objectName') { row.objectName }
            datatable-cell(name='objectItem') { row.objectItem }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='phone') { row.phone }
            //datatable-cell(name='email') { row.email }
            datatable-cell(name='comment') { _.truncate(row.comment.replace( /<.*?>/g, '' ), {length: 35}) }

    script.
        var self = this

        self.collection = 'Application'
        self.mixin('remove')

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'date', value: 'Дата'},
            {name: 'objectName', value: 'Объект'},
            {name: 'objectItem', value: ''},
            {name: 'name', value: 'Ф.И.О'},
            {name: 'phone', value: 'Телефон'},
            //{name: 'email', value: 'E-mail'},
            {name: 'comment', value: 'Комментарий'},
        ]

        self.add = function () {
            riot.route('/applications/new')
        }

        self.edit = function (e) {
            riot.route(riot.util.tmpl('/applications/{ id }', e.item.row))
        }

        app.on('applications-list-reload', function () {
            self.tags.catalog.reload()
        })