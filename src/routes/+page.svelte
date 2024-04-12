<script>
	import { onMount } from "svelte";
    import "/src/style.css";
    import * as THREE from 'three';
    import { FirstPersonControls } from 'three/addons/controls/FirstPersonControls.js';
    import GUI from 'lil-gui'; 

    let canvas;
    let controls;
    let debug, active;
    let map, bmap, dmap;

    onMount(() => {

        active = window.location.hash === '#debug';

        if (active) {
            debug = new GUI();

            // add map a dropdown list
            debug.add({ map: 'map-srchrs-v2.png' }, 'map', ['map-srchrs-v0.png', 'map-srchrs-v1.png','map-srchrs-v2.png', 'map-srchrs-v3.png', 'map-srchrs-v4.png', 'map-srchrs-v5.png', 'map-srchrs-v6.png']).onChange((value) => {
                console.log(value);
                map = new THREE.TextureLoader().load(`/${value}`);
                bmap = new THREE.TextureLoader().load(`/${value}`);
                dmap = new THREE.TextureLoader().load(`/${value}`);
                plane.material.map = map;
                plane.material.needsUpdate = true;
            });

        }

        const sizes = {
            width: window.innerWidth,
            height: window.innerHeight
        };

        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
        const renderer = new THREE.WebGLRenderer({ 
            canvas,
            antialias: true,
        });
        renderer.physicallyCorrectLights = true;
        renderer.outputColorSpace = THREE.SRGBColorSpace;
        renderer.toneMapping = THREE.CineonToneMapping;
        renderer.toneMappingExposure = 1.75;
        renderer.shadowMap.enabled = true;
        renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        renderer.setSize(sizes.width, sizes.height);
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

        map = new THREE.TextureLoader().load("/map-srchrs-v2.png");
        bmap = new THREE.TextureLoader().load("/map-srchrs-v2.png");
        dmap = new THREE.TextureLoader().load("/map-srchrs-v2.png");

        // Create plane geometry
        const geometry = new THREE.PlaneGeometry(sizes.width, sizes.width, 500, 500);

        const material = new THREE.MeshPhongMaterial({
            bumpMap: bmap,
            bumpScale: 2.,
            map: map,
            displacementMap: dmap,
            displacementScale: 10.0,

         })

        camera.position.y = 200;
        camera.rotation.x = -Math.PI / 4;

        //import orbitControls
        controls = new FirstPersonControls( camera, renderer.domElement );
        // controls.autoForward = true;
        // controls.movementSpeed = 150;
        controls.lookSpeed = .0025;        
        
        const plane = new THREE.Mesh(geometry, material);
        plane.rotation.x = -Math.PI / 2;
        scene.add(plane);

        const ambientLight = new THREE.AmbientLight(0xffffff, 1.0); // Color, Intensity
        scene.add(ambientLight);


        scene.fog = new THREE.Fog(0x080500, 1, 700); // color, near, far

        const animate = function () {
            requestAnimationFrame(animate);

            plane.rotation.z += 0.0005;
            
            if (controls) {controls.update(.05)};
            renderer.render(scene, camera);
        };

        animate();
        
        onresize = () => {
            sizes.width = window.innerWidth;
            sizes.height = window.innerHeight;

            camera.aspect = sizes.width / sizes.height;
            camera.updateProjectionMatrix();

            controls.handleResize();
            renderer.setSize(sizes.width, sizes.height);
        };
    });
</script>

<canvas bind:this={canvas}></canvas>

<h1 class="text-white absolute left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 text-6xl select-none">SRCHRS</h1>
