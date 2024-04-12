<script>
	import { onMount } from "svelte";
    import "/src/style.css";
    import * as THREE from 'three';
    import vertexShader from '$lib/glsl/vertex.glsl';
    import fragmentShader from '$lib/glsl/fragment.glsl';
    import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
    

    let canvas;
    let bumpMap;

    onMount(() => {
        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        const renderer = new THREE.WebGLRenderer({ canvas: canvas });

        renderer.setSize(window.innerWidth, window.innerHeight);

        // create setting with sizes
        const sizes = {
            width: window.innerWidth,
            height: window.innerHeight
        };

        let map = new THREE.TextureLoader().load("/map-srchrs-v2.png");
        let bmap = new THREE.TextureLoader().load("/map-srchrs-v2.png");
        let dmap = new THREE.TextureLoader().load("/map-srchrs-v2.png");
                    

        console.log(bmap)


        // Create plane geometry
        const geometry = new THREE.PlaneGeometry(sizes.width, sizes.height, 1080, 1080);
        // const geometry = new THREE.PlaneGeometry(sizes.width, sizes.height);


        // const material = new THREE.ShaderMaterial({
        //     vertexShader: vertexShader,
        //     fragmentShader: fragmentShader
        // });

        const material = new THREE.MeshStandardMaterial({
            // color: 0xff0000,
            bumpMap: bmap,
            bumpScale: 10.,
            map: map,
            displacementMap: dmap,
            displacementScale: 5.0,

         })

         camera.position.x = 0;
        //  camera.position.y = -120;
         camera.position.z = 170;

        //import orbitControls
        const controls = new OrbitControls( camera, renderer.domElement );
        
        controls.minPolarAngle = Math.PI - (Math.PI * 2/3);
        controls.maxPolarAngle = Math.PI * 2/3;
        controls.minAzimuthAngle = -Math.PI / 8;
        controls.maxAzimuthAngle = Math.PI / 8;

        // Create mesh with geometry and material
        const plane = new THREE.Mesh(geometry, material);
        scene.add(plane);


        // Add ambient light
        const ambientLight = new THREE.AmbientLight(0xffffff, 1.0); // Color, Intensity
        scene.add(ambientLight);

        scene.fog = new THREE.Fog(0x000000, 1, 400); // color, near, far


        const animate = function () {
            requestAnimationFrame(animate);

            // plane.rotation.x += 0.01;
            plane.rotation.z += 0.001;
            // plane.rotation.y += 0.00025;

            renderer.render(scene, camera);
        };

        animate();
    });
</script>

<canvas bind:this={canvas}></canvas>

<h1 class="text-white absolute left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 text-6xl">SRCHRS</h1>
