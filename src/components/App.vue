<template>
  <main>
    <header class="py-3 mb-3 border-bottom">
      <div class="container-fluid d-grid gap-3 align-items-center" style="grid-template-columns: 1fr 2fr;">
        <router-link to="/" class="pull-left" style="width: 40px;">
          <img src="/favicon/apple-touch-icon.png" width="40px"/>
        </router-link>

        <div class="d-flex align-items-center" style="width: 50%;">
          <form class="me-3" style="width: 100%;">
            <input type="search" class="form-control" v-model="search" placeholder="LEGO Set Nummer..." aria-label="Search" style="width: 100%;">
          </form>
        </div>
      </div>
    </header>

    <div class="container-fluid">
      <router-view></router-view>
    </div>

  </main>
</template>
<script>
  export default {
    name: 'app',
    data: function() {
      return {
        search: '',
      }
    },
    watch: {
      search: function (search) {
        this.$router.push('/set/' + this.search + '-1');
      },
    }
  }
</script>
