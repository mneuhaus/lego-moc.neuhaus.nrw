import Vue from 'vue';
import Router from 'vue-router';
import VueResource from 'vue-resource';

Vue.config.productionTip = false;
Vue.use(Router);
Vue.use(VueResource);

require.context('./components/', true, /\.vue$/).keys().forEach(function (elementPath) {
    let element = require('./components/' + elementPath.replace('./', '')).default;
    Vue.component(element.name, element);
});


var router = new Router({
    routes: [
        {
            path: '/',
            name: 'Index',
            component: require('./views/IndexView.vue').default,
        },
        {
            path: '/set/:set_num',
            name: 'Set',
            component: require('./views/SetView.vue').default,
        },
    ],
});

new Vue({
    el: '#app',
    router,
    template: '<app/>',
});
