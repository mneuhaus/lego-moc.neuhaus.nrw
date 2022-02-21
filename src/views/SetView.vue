<template>
  <div>
    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-4">
      <template v-if="items.length > 0">
        <div class="col" v-for="item in items">
          <a :href="item.moc_url" target="_blank" class="card shadow-sm" >
            <div class="card-img-top" v-bind:style="{ backgroundImage: 'url(' + item.moc_img_url + ')' }">&nbsp;</div>
            <div class="card-footer">
              <p class="card-text"><strong>{{item.name}}</strong> ({{item.set_num.replace('-1', '')}})</p>
            </div>
          </a>
        </div>
      </template>
      <div v-else style="opacity: 0.5; margin: 50px auto;">
        <svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
             viewBox="0 0 295.996 295.996" style="enable-background:new 0 0 295.996 295.996;" xml:space="preserve">
<g>
	<path d="M147.998,0C66.392,0,0,66.392,0,147.998c0,81.606,66.392,147.998,147.998,147.998c81.606,0,147.998-66.392,147.998-147.998
		C295.996,66.392,229.604,0,147.998,0z M147.998,279.996c-36.257,0-69.143-14.696-93.023-38.44
		c-9.536-9.482-17.631-20.41-23.934-32.42C21.442,190.847,16,170.047,16,147.998C16,75.214,75.214,16,147.998,16
		c34.523,0,65.987,13.328,89.533,35.102c12.208,11.288,22.289,24.844,29.558,39.996c8.27,17.239,12.907,36.538,12.907,56.9
		C279.996,220.782,220.782,279.996,147.998,279.996z"/>
  <path d="M163.638,187.607c17.554,3.671,33.322,13.54,44.4,27.789l12.631-9.82c-13.402-17.24-32.494-29.184-53.756-33.631
		c-34.195-7.146-70.146,6.052-91.587,33.631l12.633,9.82C105.675,192.607,135.382,181.697,163.638,187.607z"/>
  <circle cx="98.666" cy="114.998" r="16"/>
  <circle cx="197.666" cy="114.998" r="16"/>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
          <g>
</g>
</svg>

      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'set-view',
  data: function() {
    return {
      set:null,
      items: []
    }
  },
  created() {
    // watch the params of the route to fetch the data again
    this.$watch(
        () => this.$route.params,
        () => {
          this.fetchData()
        },
        // fetch the data when the view is created and the data is
        // already being observed
        { immediate: true }
    )
  },
  methods: {
    fetchData() {
      this.$http.get("https://rebrickable.com/api/v3/lego/sets/" + this.$route.params.set_num + '/alternates/', {
        headers: {
          Authorization: "key 83891d44bde76ea408ff6d1ce186dd55"
        }
      })
      .then((response) => {
        if (response.body.results) {
          this.items = response.body.results;
        }
      });
    },
  },
};
</script>
