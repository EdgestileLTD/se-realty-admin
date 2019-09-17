| import 'components/catalog.tag'
| import 'lodash/lodash'
| import 'components/star-rating.tag'

reviews-list

    catalog(object='Review', cols='{ cols }', reload='true', search='true', sortable='true',
    add='{ permission(add, "reviews", "0100") }',
    remove='{ permission(remove, "reviews", "0001") }',
    dblclick='{ permission(open, "reviews", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='date') { row.date }
            datatable-cell(name='userName') { row.name }
            datatable-cell(name='email') { row.email }
            datatable-cell(name='commentary') { _.truncate(row.commentary.replace( /<.*?>/g, '' ), {length: 50}) }


    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Review'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'date', value: 'Дата'},
            {name: 'name', value: 'Пользователь'},
            {name: 'email', value: 'E-mail'},
            {name: 'commentary', value: 'Отзыв'},
        ]

        self.add = e => riot.route(`/reviews/new`)

        self.open = e => riot.route(`/reviews/${e.item.row.id}`)

        observable.on('reviews-reload', () => self.tags.catalog.reload())


