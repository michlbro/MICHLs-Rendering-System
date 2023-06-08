local setup = {}

function setup.GetMaterialFunction(materials)
    local materials = materials:DumpMaterials()
    print(materials)
    return function(instance)
        local material = {}
        material.colour = instance.Color
        if instance.ClassName == "Terrain" then
            material.colour = instance:GetMaterialColor()
        end
        local materialObj = materials[instance.Material] or materials.None
        for property, value in materialObj do
            material[property] = value
        end
        return material
    end
end

function setup.Ray(scene)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = scene.objects
    rayParams.FilterType = Enum.RaycastFilterType.Include

    return function(origin, direction, length)
        local rayResult = workspace:Raycast(origin, direction * length, rayParams)

        local ray = {}
        ray.Intersected = rayResult and rayResult.Instance and true or false
        if not ray.Intersected then
            return ray
        end
        ray.Position = rayResult.Position
        ray.Normal = rayResult.Normal
        ray.Material = rayResult.Material
        ray.Instance = rayResult.Instance
        ray.Direction = direction
        ray.Origin = rayResult.Instance.Position

        return ray
    end
end

function setup.Color3ToVector3(color3)
    return Vector3.new(color3.R, color3.G, color3.B)
end

function setup.SetupPipeline(scene, materials, camera)
    local config = {}

    config.material = setup.GetMaterialFunction(materials)
    config.ray = setup.Ray(scene, camera)
    config.camera = camera
    config.Color3ToVector3 = setup.Color3ToVector3
    config.MaxBounce = 2
    config.MaxRays = 100

    return config
end

return setup
