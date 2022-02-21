<template>
  <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-4">
    <div class="col" v-for="item in items" >
      <router-link :to="'/set/' + item.set_num" class="card shadow-sm" >
        <div class="card-img-top" v-bind:style="{ backgroundImage: 'url(' + item.set_img_url + ')' }">&nbsp;</div>
        <div class="card-footer">
          <p class="card-text"><strong>{{item.name}}</strong> ({{item.set_num.replace('-1', '')}})</p>
        </div>
      </router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'index-view',
  data: function() {
    return {
      items: []
    }
  },
  mounted: function() {
    this.$http
    .get("https://rebrickable.com/api/v3/lego/sets/?min_year=2018&ordering=-year&theme_id=672", {
      headers: {
        Authorization: "key 83891d44bde76ea408ff6d1ce186dd55"
      }
    })
    .then((response) => {
      if (response.body.results) {
        this.items = response.body.results;
      }
    });
  }
};
</script>
