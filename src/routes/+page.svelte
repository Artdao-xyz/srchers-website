<script>
	import { onMount } from "svelte";
    import "/src/style.css";
    import * as THREE from 'three';
    import { FirstPersonControls } from 'three/addons/controls/FirstPersonControls.js';
    import GUI from 'lil-gui'; 
    import CustomShaderMaterial from 'three-custom-shader-material/vanilla'
    import vertexShader from '$lib/glsl/vertex.glsl'
    import fragmentShader from '$lib/glsl/fragment.glsl'
    import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
    import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
    import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js'
    import { FXAAShader } from 'three/examples/jsm/shaders/FXAAShader.js'
    import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'
    import { FilmPass } from 'three/examples/jsm/postprocessing/FilmPass.js'
    import { BokehPass } from 'three/examples/jsm/postprocessing/BokehPass.js'
	import TextScramble from '$lib/TextScramble.js';
    import Subscribe from '$lib/Subscribe.svelte';

    let canvas, h1, h2a, h2b, h2c, controls, active;
    let wrapper;
    let loaded = false;
    
    onMount(async() => {

        active = window.location.hash === '#debug';

        const sizes = {
            width: canvas.parentElement.clientWidth,
            height: canvas.parentElement.clientHeight + 120,
            pixelRatio: Math.min(window.devicePixelRatio, 2)
        };

        const scene = new THREE.Scene();

        const renderer = new THREE.WebGLRenderer({
            canvas,
            alpha: true,
            antialias: true,
            powerPreference: 'high-performance',
        })
        renderer.outputEncoding = THREE.sRGBEncoding;
        renderer.shadowMap.enabled = true
        renderer.shadowMap.type = THREE.PCFSoftShadowMap
        renderer.toneMapping = THREE.ACESFilmicToneMapping
        renderer.toneMappingExposure = 1.3
        renderer.setSize(sizes.width, sizes.height)
        renderer.setPixelRatio(sizes.pixelRatio);
        scene.background = new THREE.Color('#F6F4F3')

        const resolutionPlane = { 'Resolution' : 500 }

        const geometry = new THREE.PlaneGeometry(5, 5, resolutionPlane.Resolution, resolutionPlane.Resolution)
        geometry.deleteAttribute('uv')
        geometry.deleteAttribute('normal')
        geometry.rotateX(- Math.PI * 0.5)
        // geometry.rotateY(- Math.PI * 0.5)
        // geometry.translate(0.0, 0.0, 0.0 )
        
        const uniforms = {
            uTime: new THREE.Uniform(0),
            uPositionFrequency: new THREE.Uniform(0.55),
            uStrength: new THREE.Uniform(0.65),
            uWarpFrequency: new THREE.Uniform(20.0),
            uWarpStrength: new THREE.Uniform(0.005),
        }
        
        const material = new CustomShaderMaterial({
            // CSM
            baseMaterial: THREE.MeshStandardMaterial,
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            uniforms: uniforms,
            silent: true,

            // MeshPhysicalMaterial
            metalness: 0.9,
            roughness: 0.9,
            color: '#F6F4F3',
        })

        const terrain = new THREE.Mesh(geometry, material)
        terrain.castShadow = true
        terrain.receiveShadow = true
        scene.add(terrain)
        let lightColor = '#F6F4F3';
        let directionalLight = new THREE.DirectionalLight(lightColor, 2.0)
        directionalLight.position.set(-6.25, 8, -4)
        directionalLight.castShadow = true
        directionalLight.shadow.mapSize.set(1024, 1024)
        directionalLight.shadow.camera.near = 0.1
        directionalLight.shadow.camera.far = 30
        directionalLight.shadow.camera.top = 8
        directionalLight.shadow.camera.right = 8
        directionalLight.shadow.camera.bottom = -8
        directionalLight.shadow.camera.left = -8
        scene.add(directionalLight)
        
        const ambientLight = new THREE.AmbientLight('#F6F4F3', .5)
        scene.add(ambientLight)

        const camera = new THREE.PerspectiveCamera(30, sizes.width / sizes.height, 0.1, 100)
        camera.position.set(0, 0.4, 0);
        camera.rotation.x = -Math.PI / 5;
  
        //debug view
        // camera.position.set(0, 10.20, 0);
        // camera.rotation.x = -Math.PI / 2;

        scene.add(camera)

        //FirstPersonControls
        controls = new FirstPersonControls(camera, wrapper);
        controls.lookVertical = false;
        controls.movementSpeed = 0.0;
        controls.lookSpeed = .002;        
        
        const fog = new THREE.Fog('#F6F4F3', 0.001, 2.28);
        scene.fog = fog;

        const composer = new EffectComposer(renderer);
        composer.setSize(sizes.width, sizes.height);
        composer.setPixelRatio(sizes.pixelRatio);
        composer.addPass(new RenderPass(scene, camera));

        const effectFXAA = new ShaderPass(FXAAShader);
        effectFXAA.uniforms['resolution'].value.set(1 / ( sizes.width * sizes.pixelRatio ), 1 / ( sizes.height * sizes.pixelRatio ));
        composer.addPass(effectFXAA);

        const bokehPass = new BokehPass(scene, camera, {
            focus: 0.15,
            aperture: 0.005,
            maxblur: 0.005,
            width: sizes.width,
            height: sizes.height
        });
        composer.addPass(bokehPass);

        const bloomPass = new UnrealBloomPass(new THREE.Vector2(sizes.width, sizes.height), 1.5, 0.4, 1.25);
        bloomPass.enabled = false;
        composer.addPass(bloomPass);

        const filmPass = new FilmPass(0.25, 0.025, 648, false);
        composer.addPass(filmPass);

        onresize = () => {

            if (window.innerWidth !== sizes.width) {

                sizes.width = window.innerWidth;
                sizes.height = window.innerHeight;

                camera.aspect = sizes.width / sizes.height;
                camera.updateProjectionMatrix();

                controls.handleResize();
                renderer.setSize(sizes.width, sizes.height);
                renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

            };
            
        };

        const clock = new THREE.Clock()
        let uTimeAmount = 0.05;

        loaded = true;
        setTimeout(() => scramble(), 0);

        const tick = () => {
            const elapsedTime = clock.getElapsedTime()

            uniforms.uTime.value = elapsedTime * uTimeAmount;

            if (controls) {controls.update(.05)};
            composer.render()
            window.requestAnimationFrame(tick)
        }
        tick()

        if (active) {
            let gui = new GUI();

            const folderShader = gui.addFolder('Shader');

            folderShader.add(uniforms.uPositionFrequency, 'value', 0.5, 0.85, 0.001).name('uPositionFrequency')
            folderShader.add(uniforms.uStrength, 'value', 0.35, 0.95, 0.001).name('uStrength')
            folderShader.add(uniforms.uWarpFrequency, 'value', 0, 0.5, 0.001).name('uWarpFrequency')
            folderShader.add(uniforms.uWarpStrength, 'value', 0, 4, 0.001).name('uWarpStrength')
            folderShader.add({ uTimeAmount: uTimeAmount }, 'uTimeAmount', 0, 5, 0.001).name('uVelocity').onChange((value) => {
                uTimeAmount = value
            })
            const lightFolder = gui.addFolder('Light')
            lightFolder.addColor({ lightColor: '#F6F4F3' }, 'lightColor').name('color').onChange((value) => {
                directionalLight.color.set(value)
            })
            lightFolder.add(directionalLight, 'intensity', 0, 7, 0.001).name('intensity');
            const cameraFolder = gui.addFolder('Camera')
            cameraFolder.add(camera.position, 'y', 0, 10, 0.001).name('Y')

            const postProcessFolder = gui.addFolder('Post Process')
            postProcessFolder.add(filmPass, 'enabled').name('Film Pass')
            postProcessFolder.add(effectFXAA, 'enabled').name('FXAA')
            postProcessFolder.add(bloomPass, 'enabled').name('Bloom')
            postProcessFolder.add(bloomPass, 'threshold', 0, 1, 0.001).name('Bloom Threshold')
            postProcessFolder.add(bokehPass, 'enabled').name('Bokeh')
            postProcessFolder.add(fog, 'far', 0.001, 15, 0.001).name('Fog Far')
            postProcessFolder.addColor({ fogColor: '#F6F4F3' }, 'fogColor').name('Fog Color').onChange((value) => {
                scene.fog.color.set(value)
            })
        }
    });

    const scramble = async () => {

        const title1 = 'SRCHERS';
        const title = new TextScramble(h1, title1, 15);
        await title.start();

        const title4 = 'BEYOND DIFFERENT';
        const subtitle3 = new TextScramble(h2c, title4, 15);
        await subtitle3.start();

        const title2 = 'LAUNCHING';
        const subtitle1 = new TextScramble(h2a, title2, 15);
        await subtitle1.start();

        const title3 = '2025';
        const subtitle2 = new TextScramble(h2b, title3, 15);
        await subtitle2.start();

    }
</script>


<div class="fixed top-0 left-0 -z-10 h-full w-full">
    <canvas bind:this={canvas}></canvas>
</div>

<div bind:this={wrapper} class="max-w-[1440px] h-full font-jetbrains-mono text-alternative-black mx-auto">

    {#if loaded}

        <a class="absolute left-6 top-6 lg:left-9" href="https://www.instagram.com/srchers/" target="_blank"><img src="/ig.svg"  alt="Instagram"></a>

        <div class="h-svh flex flex-col justify-between lg:justify-center items-center lg:gap-20 py-20">
            <div>
                <h1 on:mouseenter={scramble} bind:this={h1} class="text-center text-5xl lg:text-7xl font-semibold leading-10 tracking-wide">SRCHERS</h1>
                <p bind:this={h2c} class="text-center text-lg lg:text-2xl font-medium uppercase leading-relaxed mt-4 lg:mt-3">Beyond different</p>
            </div>
            
            <img class="w-52 lg:w-64 h-52 lg:h-64" src="/srchers-logo-optimize.gif" alt="Logo">

            <div class="flex items-center gap-3">
                <h2 bind:this={h2a} class="text-center text-xl lg:text-2xl font-medium tracking-10">LAUNCHING</h2>
                <h2 bind:this={h2b} class="text-center text-xl lg:text-2xl font-medium tracking-10">2025</h2>
            </div>

            <a href="#text"><img class="animate-pulse" src="/arrow.png" alt="scroll"></a>
        </div>

        <div id="text" class="h-screen flex flex-col justify-center items-center">
            
            <Subscribe />
        </div>
        {/if}
</div>