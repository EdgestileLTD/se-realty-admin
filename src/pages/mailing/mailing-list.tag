| import 'components/catalog.tag'
| import 'lodash/lodash'

mailing-list

    catalog(object='Mailing', cols='{ cols }', reload='true', search='true', sortable='true',
    add='{ permission(add, "reviews", "0100") }',
    remove='{ permission(remove, "reviews", "0001") }',
    dblclick='{ permission(open, "reviews", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='dateDisplay') { row.senderDateDisplay }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='subject') { row.subject }
            datatable-cell(name='body') { _.truncate(row.body.replace( /<.*?>/g, '' ), {length: 50}) }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Mailing'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'dateDisplay', value: 'Дата отправки'},
            {name: 'name', value: 'Имя рассылки/кампании'},
            {name: 'subject', value: 'Тема письма'},
            {name: 'body', value: 'Тело письма'},
        ]

        self.add = e => riot.route(`/mailing/new`)

        self.open = e => riot.route(`/mailing/${e.item.row.id}`)

        observable.on('mailing-reload', () => self.tags.catalog.reload())


